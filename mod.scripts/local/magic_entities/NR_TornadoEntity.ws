statemachine class NR_TornadoEntity extends CGameplayEntity {
	protected var m_caster, m_target : CActor;
	protected var m_targetPos : Vector;
	public var m_metersPerSec : float;

	protected var m_tornadoLifetime, m_victimDistance, m_victimDistanceSq, m_slideDistance, m_slideDistanceSq : float;
	protected var m_respectCaster : bool;
	protected var m_pursueTarget : bool;
	protected var m_suckTargets : bool;
	protected var m_fxName : name;
	protected var m_victimEffects : array<EEffectType>;

	default m_victimDistance = 3.f;
	default m_victimDistanceSq = 9.f;
	default m_slideDistance = 12.f;
	default m_slideDistanceSq = 144.f;
	default m_metersPerSec = 3.f;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
	// if target is NULL, then static pos is used
	public function Activate(caster : CActor, target : CActor, targetPos : Vector, effectName : name,
							lifetime : float, respectCaster : bool, suck : bool, pursue : bool, is_freezing : bool) {
		m_caster = caster;
		m_target = target;
		m_targetPos = targetPos;
		m_tornadoLifetime = lifetime;
		m_respectCaster = respectCaster;
		m_suckTargets = suck;
		m_pursueTarget = pursue;
		m_fxName = effectName;
		m_victimEffects.PushBack(EET_Bleeding);
		if (is_freezing) {
			m_victimEffects.PushBack(EET_SlowdownFrost);
		}
		GotoState('Active');
	}

	/* to stop before lifetime elapsed */
	public function ForceStop() {
		GotoState('Stop');
	}
}

state Active in NR_TornadoEntity {
	protected var startTime		: float;
	protected var victims		: array<CActor>;
	protected var slideVictims	: array<CActor>;
	protected var slideVictimTickets : array<SMovementAdjustmentRequestTicket>;

	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Active: OnEnterState");
		parent.PlayEffect( parent.m_fxName );
		MainLoop();
	}

	event OnLeaveState( nextStateName : name )
	{
		var actorVictim				: CActor;
		var i, j					: int;

		NR_Debug("Active: OnLeaveState");
		parent.StopEffect( parent.m_fxName );
		victims.Clear();
	}

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	entry function MainLoop() {
		var moveTime, lastMoveTime, distSq 	: float;
		var damageTime, lastDamageTime, damageVal, dk : float;
		var currentPos, targetPos, reachPos : Vector;
		var entities 	: array<CGameplayEntity>;
		var actor 		: CActor;
		var i, j 		: int;
		var damage 		: W3DamageAction;

		startTime = theGame.GetEngineTimeAsSeconds();
		lastMoveTime = GetLocalTime();
		lastDamageTime = lastMoveTime;
		dk = 20.f;

		currentPos = parent.GetWorldPosition();
		if (parent.m_target) {
			reachPos = parent.m_target.GetWorldPosition();
		} else {
			reachPos = currentPos;
		}
		targetPos = reachPos;

		while ( GetLocalTime() < parent.m_tornadoLifetime ) {
			SleepOneFrame();
			/* move tornado */
			moveTime = GetLocalTime() - lastMoveTime;
			if (moveTime < 0.03f)
				continue;

			if (parent.m_pursueTarget) {
				if (parent.m_target) {
					reachPos = parent.m_target.GetWorldPosition();
				}

				NR_SmoothMoveToTarget(moveTime, parent.m_metersPerSec, currentPos, targetPos, reachPos);
				NR_Debug("Tornado: moveTime = " + moveTime + ", currentPos = " + VecToString(currentPos));
				parent.Teleport(currentPos);
			}
			lastMoveTime = GetLocalTime();

			/* check and damage victims */
			damageTime = GetLocalTime() - lastDamageTime;
			if (damageTime < 0.25f)
				continue;

			// remove old slide victims if out
			for ( i = slideVictims.Size() - 1; i >= 0; i -= 1 )
			{
				distSq = VecDistanceSquared2D(currentPos, slideVictims[i].GetWorldPosition());
				if ( distSq > parent.m_slideDistanceSq ) {
					RemoveSlideVictimByIndex(i);
				}
			}

			// add new slide victims if in
			entities.Clear();
			FindGameplayEntitiesInRange( entities, this.parent, parent.m_slideDistance, 999 );
			for ( i = 0; i < entities.Size(); i += 1 )
			{
				actor = (CActor)entities[i];
				if (!actor || !actor.IsInCombat())
					continue;

				if (actor == parent.m_caster)
					continue;

				if ( !slideVictims.Contains(actor) ) {
					AddSlideVictim(actor);
				}
			}


			// remove old victims if out
			for ( i = victims.Size() - 1; i >= 0; i -= 1 )
			{
				distSq = VecDistanceSquared2D(currentPos, victims[i].GetWorldPosition());
				if ( !victims[i].IsAlive() || distSq > parent.m_victimDistanceSq ) {
					victims.Erase(i);
				}
			}

			// add new victims if in
			entities.Clear();
			FindGameplayEntitiesInRange( entities, this.parent, parent.m_victimDistance, 999, , FLAG_OnlyAliveActors );
			for ( i = 0; i < entities.Size(); i += 1 )
			{
				actor = (CActor)entities[i];
				if (!actor || !actor.IsAlive())
					continue;

				if (parent.m_respectCaster && GetAttitudeBetween(actor, parent.m_caster) != AIA_Hostile)
					continue;

				if ( !victims.Contains(actor) ) {
					victims.PushBack(actor);
				}
			}

			// add damage with buffs to entities
			for ( i = 0; i < victims.Size(); i += 1 )
			{
				damage = new W3DamageAction in this;
				damage.Initialize(parent.m_caster, victims[i], NULL, parent, EHRT_None, CPS_Undefined, false, false, false, true );
				damageVal = GetDamage(victims[i], /*min*/ 2.f*dk, /*max*/ 50.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/);
				damageVal = damageVal * damageTime / 7.f;
				damage.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, damageVal );
				//damage.SetCanPlayHitParticle( false );
				damage.SetSuppressHitSounds( true );
				damage.SetHitAnimationPlayType( EAHA_ForceNo );
				for (j = 0; j < parent.m_victimEffects.Size(); j += 1) {
					damage.AddEffectInfo(parent.m_victimEffects[j], 0.25f);
				}
				theGame.damageMgr.ProcessAction( damage );
					
				delete damage;
			}
			lastDamageTime = GetLocalTime();
		}
		parent.GotoState('Stop');
	}

	latent function AddSlideVictim(victim : CActor) {
		var ticket : SMovementAdjustmentRequestTicket;
		var movementAdjustor : CMovementAdjustor;

		movementAdjustor = victim.GetMovingAgentComponent().GetMovementAdjustor();
		ticket = movementAdjustor.CreateNewRequest( 'NR_TornadoEntity_Suck' );
		// movementAdjustor.RotateTowards( ticket, parent );
		movementAdjustor.Continuous( ticket );
		movementAdjustor.SlideTowards( ticket, parent, 0.f, 2.f );
		movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 1.5f );
		// movementAdjustor.ScaleAnimation( ticket, true, true, true );
		movementAdjustor.AdjustLocationVertically( ticket, true );
		movementAdjustor.DontEnd( ticket );
		// movementAdjustor.KeepActiveFor( ticket, parent.m_tornadoLifetime - GetLocalTime() );
		NR_Debug("AddSlideVictim: " + victim);

		slideVictims.PushBack(victim);
		slideVictimTickets.PushBack(ticket);
	}

	latent function RemoveSlideVictimByIndex(victimIndex : int) {
		var ticket : SMovementAdjustmentRequestTicket;
		var movementAdjustor : CMovementAdjustor;

		ticket = slideVictimTickets[victimIndex];
		movementAdjustor = slideVictims[victimIndex].GetMovingAgentComponent().GetMovementAdjustor();
		if ( movementAdjustor.IsRequestActive(ticket) ) {
			movementAdjustor.Cancel(ticket);
		}

		slideVictims.Erase(victimIndex);
		slideVictimTickets.Erase(victimIndex);
	}

	latent function GetDamage(damageTarget : CActor, minPerc : float, maxPerc : float, basicVitality : float, addVitality : float, basicEssence : float, addEssence : float, optional randMin : float, optional randMax : float) : float {
		var damage, maxDamage, minDamage : float;
		var levelDiff : float;

		if (randMin < 0.1) {
			randMin = 0.9;
		}
		if (randMax < 0.1) {
			randMax = 1.1;
		}

		if (damageTarget) {
			levelDiff = thePlayer.GetLevel() - damageTarget.GetLevel();
			maxDamage = damageTarget.GetMaxHealth() * maxPerc / 100.f + levelDiff * 1.f;
			minDamage = MaxF(damageTarget.GetMaxHealth() * 0.5f / 100.f, damageTarget.GetMaxHealth() * minPerc / 100.f + levelDiff * 0.1f);
		} else {
			levelDiff = 0;
			maxDamage = 1000000.f;
			minDamage = 1.f;
		}

		if (damageTarget.UsesVitality()) {
			damage = basicVitality + addVitality * thePlayer.GetLevel();
		} else {
			damage = basicEssence + addEssence * thePlayer.GetLevel();
		}
		damage = damage * NR_GetRandomGenerator().nextRangeF(randMin, randMax);

		if (damageTarget) {
			damage = MinF(maxDamage, damage);
			damage = MaxF(minDamage, damage);
		}
		NR_Debug("Tornado: GetDamage: minDamage = " + minDamage + ", maxDamage = " + maxDamage + ", final damage = " + damage);
		return damage;
	}
}
state Stop in NR_TornadoEntity {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Stop: OnEnterState");
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Stop: OnLeaveState");
	}
}
