// edited CMagicBombEntity to control extra params 
statemachine class NR_MagicBombEntity extends CGameplayEntity
{
	protected var m_caster, m_target 	: CActor;
	editable var m_respectCaster		: bool;
	editable var m_pursueTarget			: bool;
	editable var m_damageRadius			: float;
	editable var m_damageVal			: float;
	editable var m_timeToExplode		: float;
	editable var m_metersPerSec			: float;
	editable var m_damageType			: name;
	editable var m_fxName				: name;
	editable var m_explosionFxName		: name;
	default m_timeToExplode 	= 2.5f;
	default m_metersPerSec 		= 2.5f;
	default m_damageRadius 		= 3.f;
	default m_damageVal 		= 100.f;
	default m_damageType 		= 'ElementalDamage';
	default m_fxName 			= 'arcane_circle';
	default m_explosionFxName 	= 'explosion';

	function Init( caster : CActor, target : CActor, respectCaster : bool, pursueTarget : bool )
	{
		m_caster = caster;
		m_target = target;
		m_respectCaster = respectCaster;
		m_pursueTarget = pursueTarget;
		NR_Debug("NR_MagicBombEntity: Init, m_target = " + m_target);
		GotoState('Active');
	}
}

state Active in NR_MagicBombEntity {
	protected var l_startTime : float;

	event OnEnterState( prevStateName : name )
	{
		NR_Debug("NR_MagicBombEntity: OnEnterState");
		parent.PlayEffect( parent.m_fxName );
		MainLoop();
	}

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - l_startTime;
	}

	entry function MainLoop() {
		var moveTime, lastMoveTime : float;
		var currentPos, targetPos, reachPos : Vector;

		l_startTime = theGame.GetEngineTimeAsSeconds();
		lastMoveTime = GetLocalTime();

		currentPos = parent.GetWorldPosition();
		if (parent.m_target) {
			reachPos = parent.m_target.GetWorldPosition();
		} else {
			reachPos = currentPos;
		}
		targetPos = reachPos;

		while ( GetLocalTime() < parent.m_timeToExplode ) {
			SleepOneFrame();
			moveTime = GetLocalTime() - lastMoveTime;

			if (moveTime < 0.03f)
				continue;

			if (parent.m_pursueTarget) {
				if (parent.m_target) {
					reachPos = parent.m_target.GetWorldPosition();
				}

				NR_SmoothMoveToTarget(moveTime, parent.m_metersPerSec, currentPos, targetPos, reachPos);
				NR_Debug("Bomb: moveTime = " + moveTime + ", currentPos = " + VecToString(currentPos));
				parent.Teleport(currentPos);
			}
			lastMoveTime = GetLocalTime();
		}
		Explosion();
	}

	latent function Explosion() {
		var entitiesInRange : array<CGameplayEntity>;
		var victim : CActor;
		var dEnt   : W3DestroyableClue;
		var damage : W3DamageAction;
		var i : int;

		NR_Debug("Bomb: Explosion");
		parent.StopEffect(parent.m_fxName);
		parent.PlayEffect(parent.m_explosionFxName);
		GCameraShake( 0.5, true, parent.GetWorldPosition(), 15.0f );
		FindGameplayEntitiesInRange( entitiesInRange, parent, parent.m_damageRadius, 250 );

		for ( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			victim = (CActor)entitiesInRange[i];
			if ( victim && (!parent.m_respectCaster || GetAttitudeBetween(victim, parent.m_caster) == AIA_Hostile) )
			{
				victim.AddEffectDefault( EET_Stagger, parent, parent.GetName() );
				damage = new W3DamageAction in this;
				damage.Initialize( parent.m_caster, victim, this, parent.m_caster.GetName(), EHRT_Heavy, CPS_SpellPower, false, false, false, true );
				damage.AddDamage( parent.m_damageType, parent.m_damageVal * 0.5f );
				damage.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, parent.m_damageVal * 0.5f );
				damage.AddEffectInfo(EET_Stagger, 2.0);
				theGame.damageMgr.ProcessAction( damage );
				delete damage;
			} else {
				dEnt = (W3DestroyableClue)entitiesInRange[i];
				if (dEnt && dEnt.destroyable && !dEnt.destroyed) {
					dEnt.ProcessDestruction();
				}
			}
		}
		// explodes toxic gas
		parent.AddTag(theGame.params.TAG_OPEN_FIRE);
	}

	event OnLeaveState( nextStateName : name )
	{
	}
}