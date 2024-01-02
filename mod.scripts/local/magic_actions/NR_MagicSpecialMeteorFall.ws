statemachine class NR_MagicSpecialMeteorFall extends NR_MagicSpecialAction {
	var s_respectCaster, s_autoShield	: bool;
	protected var meteor 		: NR_MeteorProjectile;
	protected var s_interval 	: float;
	protected var s_meteorNum 	: int;
	
	default actionType = ENR_SpecialMeteorFall;
	default actionSubtype = ENR_SpecialAbstractAlt;
	default drainStaminaOnPerform = false;

	latent function OnInit() : bool {
		sceneInputs.PushBack(18);
		sceneInputs.PushBack(19);
		sceneInputs.PushBack(20);
		sceneInputs.PushBack(21);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("DamageControl");
		}
		if (newLevel == 10) {
			ActionAbilityUnlock("AutoShield");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		if (IsInSetupScene()) {
			s_lifetime = 3.f;
		} else {
			s_lifetime = 0.2f; // how long should spell work after anim ends
		}
		s_interval = 0.25f;

		resourceName = MeteorEntityName();
		NR_Debug("MeteorEntityName = " + resourceName);
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName, true);
		
		s_respectCaster = IsActionAbilityUnlocked("DamageControl");
		s_autoShield = IsActionAbilityUnlocked("AutoShield");
		s_meteorNum = SkillMaxApplies();

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var ret, super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}
	
		if ( s_autoShield && 25 >= NR_GetRandomGenerator().nextRange(1, 100) ) {
			NR_GetReplacerSorceress().CastQuenScripted();
		}

		// unwanted actions may break anim
		thePlayer.BlockAction( EIAB_Movement, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Jump, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Roll, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Dodge, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Fists, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Signs, 'TryPeformLongMagicAttack' );

		GotoState('Active');
		
		return OnPerformed(true);
	}

	latent function BreakAction() {
		super.BreakAction();
		
		GotoState('Stop');
	}

	public function ContinueAction() {
		s_lifetime = 0.2f;
	}
	
	latent function ShootMeteor(cursed : bool, center : Vector) : bool {
		var dk : float;
		var minRange : float = 3.5f;  // > explosionRadius
		var maxRange : float = 12.f;

		pos = center;
		if (cursed)
			pos += VecRingRand(0.f, minRange);
		else
			pos += VecRingRand(minRange, maxRange);
		pos = SnapToGround(pos);
		//NR_Debug("NR_MagicSpecialMeteorFall: Distance pos = " + VecDistance(thePlayer.GetWorldPosition(), pos) + ", dist2D = " + VecDistance2D(thePlayer.GetWorldPosition(), pos));
		pos.Z += 40.f;
		meteor = (NR_MeteorProjectile)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!meteor) {
			NR_Error("NR_MagicSpecialMeteorFall: No valid meteor. resourceName = " + resourceName + ", template: " + entityTemplate);
			return false;
		}
		pos.Z -= 40.f;

		dk = 3.f * SkillTotalDamageMultiplier();  // 5.f for single
		meteor.projDMG = GetDamage(/*min*/ 2.f*dk, /*max*/ 60.f*dk, /*vitality*/ 32.f, 8.f*dk, /*essence*/ 90.f, 10.f*dk /*randRange*/ /*customTarget*/);
		meteor.explosionRadius = 2.75f;
		meteor.m_shakeStrength = 0.3f;
		if (cursed)
			meteor.m_respectCaster = false;
		else
			meteor.m_respectCaster = s_respectCaster;
		meteor.Init( thePlayer );
		meteor.ShootProjectileAtPosition( meteor.projAngle, meteor.projSpeed, pos, 500.f, standartCollisions );
		meteor.DestroyAfter(10.f);

		return true;
	}

	latent function MeteorEntityName() : String
	{
		var typeName 	: name = map[sign].getN("style_" + ENR_MAToName(actionType));
		var color 		: ENR_MagicColor = NR_GetActionColor();
		NR_Debug("MeteorEntityName: typeName = " + typeName + ", color = " + color);

		return "dlc/dlcnewreplacers/data/entities/magic/meteor/nr_" + NameToString(typeName) + "_meteor_" + ENR_MCToStringShort(color) + ".w2ent";
	}
}

state Active in NR_MagicSpecialMeteorFall {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Active: OnEnterState: " + this);
		startTime = theGame.GetEngineTimeAsSeconds();
		parent.inPostState = true;
		RunWait();
	}

	entry function RunWait() {
		var i : int;

		while (parent.s_lifetime > 0.f) {
			parent.s_lifetime -= parent.s_interval;
			Sleep(parent.s_interval);
			NR_Debug("Active: ShootMeteor, s_lifetime = " + parent.s_lifetime);
			for (i = 0; i < parent.s_meteorNum; i += 1) {
				parent.ShootMeteor(/*cursed*/ false, thePlayer.GetWorldPosition());
			}
		}
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Active: OnLeaveState: " + this);
	}
}

state Cursed in NR_MagicSpecialMeteorFall {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Cursed: OnEnterState: " + this);
		parent.inPostState = true;
		Curse();
	}

	entry function Curse() {
		var playerPosition : Vector;
		var cursedInterval : float;
		
		Sleep(2.f);
		parent.s_lifetime = 2.f;
		cursedInterval = parent.s_interval * 3.f;
		
		while (parent.s_lifetime > 0.f) {
			parent.s_lifetime -= cursedInterval;
			// shoot at player pos from past
			playerPosition = thePlayer.GetWorldPosition();
			Sleep(cursedInterval);
			parent.ShootMeteor(/*cursed*/ true, playerPosition);
		}
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Cursed: OnLeaveState: " + this);
	}
}


state Stop in NR_MagicSpecialMeteorFall {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Stop: OnEnterState: " + this);
		thePlayer.UnblockAction( EIAB_Movement, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Jump, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Roll, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Dodge, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Fists, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Signs, 'TryPeformLongMagicAttack' );

		parent.inPostState = false;
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Stop: OnLeaveState: " + this);
		// can be removed from cached/cursed actions TODO CHECK
		parent.inPostState = false;
	}
}