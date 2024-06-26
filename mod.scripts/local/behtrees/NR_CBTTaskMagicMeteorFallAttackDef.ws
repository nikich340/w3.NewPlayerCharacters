class NR_CAIMagicMeteorFallSpecialAction extends CAISpecialAction
{
	default aiTreeName = "dlc\dlcnewreplacers\data\behaviortrees\npc_special_cast_ice_meteor_master.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
}

class NR_CBTTaskMagicMeteorFallAttack extends CBTTaskAttack
{
	public var deactivateAfter 					: float;
	public var activateOnAnimEvent				: name;
	public var shootInterval					: float;
	public var shootTargetSearchRadius			: float;
	public var shootMinimumRangeAroundTarget	: float;
	public var shootMaximumRangeAroundTarget	: float;
	public var nr_meteorStyleName				: name;
	public var nr_meteorColor					: ENR_MagicColor;
	
	protected var m_collisionGroups 			: array<name>;
	protected var m_meteorTemplate				: CEntityTemplate;
	protected var m_lastShootTime				: float;
	protected var m_activated					: bool;
	
	function Initialize()
	{
		m_collisionGroups = NR_GetStandartCollisionNames();
	}	
	
	latent function Main() : EBTNodeStatus
	{
		var npc 					: CNewNPC;
		var timeStart 				: float;
		var pathString 				: String;
		
		npc = GetNPC();
		if ( IsNameValid(behVarNameOnDeactivation) )
			npc.SetBehaviorVariable( behVarNameOnDeactivation, 0 );

		nr_meteorColor = NR_FinalizeColor(nr_meteorColor);
		pathString = "dlc/dlcnewreplacers/data/entities/magic/meteor/nr_" + NameToString(nr_meteorStyleName) + "_meteor_" + ENR_MCToStringShort(nr_meteorColor) + ".w2ent";
		m_meteorTemplate = (CEntityTemplate)LoadResourceAsync(pathString, true);
		
		if ( !m_meteorTemplate || !IsNameValid( activateOnAnimEvent ) )
		{
			NR_Error("NR_CBTTaskMagicMeteorFallAttack.Main: invalid m_meteorTemplate = " + m_meteorTemplate + ", or activateOnAnimEvent = " + activateOnAnimEvent);
			return BTNS_Failed;
		}

		super.Main();
		
		while ( !m_activated && GetLocalTime() < 3.f )
		{
			SleepOneFrame();
		}

		timeStart = GetLocalTime();
		m_lastShootTime = -1.f;
		while ( m_activated && timeStart + deactivateAfter > GetLocalTime() )
		{
			SleepOneFrame();
			if ( m_lastShootTime + shootInterval /* npc.GetAnimationTimeMultiplier()*/ < GetLocalTime() ) {
				m_lastShootTime = GetLocalTime();
				ShootMeteor();
			}
		}
		
		if ( IsNameValid(behVarNameOnDeactivation) )
			GetNPC().SetBehaviorVariable( behVarNameOnDeactivation, behVarValueOnDeactivation );
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == activateOnAnimEvent )
		{
			// NR_Debug("NR_CBTTaskMagicMeteorFallAttack: set m_activated, animEventName = " + animEventName);
			m_activated = true;	
			return true;
		}
		
		return false;
	}

	latent function ShootMeteor() : bool {
		var caster 	: CNewNPC = GetNPC();
		var dk 		: float;
		var pos 	: Vector;
		var meteor 	: NR_MeteorProjectile;
		var enemies : array<CActor>;
		var index 	: int;
		var groundZ : float;

		enemies = caster.GetNPCsAndPlayersInRange(shootTargetSearchRadius, 25, , FLAG_ExcludeTarget + FLAG_OnlyAliveActors + FLAG_Attitude_Hostile);
		index = RandRange(enemies.Size());
		pos = enemies[ index ].GetWorldPosition() + VecRingRand( shootMinimumRangeAroundTarget, shootMaximumRangeAroundTarget );
		if ( theGame.GetWorld().PhysicsCorrectZ(pos + Vector(0,0,5.f), groundZ) ) {
			pos.Z = groundZ;
		}

		pos.Z += 40.f;
		meteor = (NR_MeteorProjectile)theGame.CreateEntity(m_meteorTemplate, pos, enemies[ index ].GetWorldRotation());
		if (!meteor) {
			NR_Error("NR_CBTTaskMagicMeteorFallAttack.ShootMeteor: invalid meteor, template: " + m_meteorTemplate);
			return false;
		}
		pos.Z -= 40.f;

		meteor.projDMG = NR_GetDamageGeneric( "NR_CBTTaskMagicMeteorFallAttack", /*caster*/ GetNPC(), /*target*/ enemies[index], /*min*/ 20.f, /*max*/ 50.f, /*vitality*/ 30.f, 25.f, /*essence*/ 80.f, 40.f);
		meteor.explosionRadius = 2.5f;
		meteor.m_shakeStrength = 0.5f;
		meteor.m_respectCaster = true;
		meteor.m_damageName = 'FrostDamage';
		meteor.Init( caster );
		meteor.ShootProjectileAtPosition( meteor.projAngle, meteor.projSpeed, pos, 500.f, m_collisionGroups );
		meteor.DestroyAfter(10.f);
		// NR_Debug("NR_CBTTaskMagicMeteorFallAttack: ShootMeteor (" + meteor + ") at: " + VecToString(pos) + ", enemy: " + enemies[ index ]);

		return true;
	}	
	
	/*
	function OnGameplayEvent( eventName : name ) : bool
	{	
		return super.OnGameplayEvent(eventName);
	}
	*/

	/*
	function OnDeactivate()
	{
		super.OnDeactivate();
	}
	*/
}

class NR_CBTTaskMagicMeteorFallAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'NR_CBTTaskMagicMeteorFallAttack';

	editable var deactivateAfter 				: float;
	editable var activateOnAnimEvent			: name;
	editable var shootInterval					: float;
	editable var shootTargetSearchRadius		: float;
	editable var shootMinimumRangeAroundTarget	: float;
	editable var shootMaximumRangeAroundTarget	: float;
	editable var nr_meteorStyleName				: name;
	editable var nr_meteorColor					: ENR_MagicColor;
	
	default deactivateAfter 					= 6.2f;
	default activateOnAnimEvent 				= 'activate';
	default shootInterval 						= 2.f;
	default shootTargetSearchRadius 			= 15.f;
	default shootMinimumRangeAroundTarget 		= 0.f;
	default shootMaximumRangeAroundTarget 		= 3.f;
	default nr_meteorStyleName 					= 'eredin';
	default nr_meteorColor 						= ENR_ColorBlue;
}
