statemachine class NR_MagicSpecialServant extends NR_MagicSpecialAction {
	var golemEntities 		: array<CNewNPC>;
	var golemEntitiesBehIds : array<int>;
	var s_follower 		: bool;
	var s_minionCount 	: int;
	default actionType 		= ENR_SpecialServant;
	default actionSubtype = ENR_SpecialAbstract;
	default s_minionCount = 1;
	
	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 40);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			sceneInputs.PushBack(11);
			sceneInputs.PushBack(12);
			sceneInputs.PushBack(13);
			PlayScene( sceneInputs );
		}

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		switch (newLevel) {
			case 1:
				ActionAbilityUnlock("Barghest");
				break;
			case 2:
				ActionAbilityUnlock("Endrega");
				break;
			case 3:
				ActionAbilityUnlock("Arachnomorph");
				break;
			case 4:
				ActionAbilityUnlock("Arachas");
				break;
			case 5:
				ActionAbilityUnlock("Followers");
				break;
			case 6:
				ActionAbilityUnlock("EarthElemental");
				break;
			case 7:
				ActionAbilityUnlock("IceElemental");
				break;
			case 8:
				ActionAbilityUnlock("FireElemental");
				break;
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		var i 			: int;

		super.OnPrepare();
		s_follower = IsActionAbilityUnlocked("Followers");

		entityTemplate = (CEntityTemplate)LoadResourceAsync( 'nr_golem_spawn_fx' );
		m_fxNameMain = SpawnFxName();

		return OnPrepared(true);
	}

	latent function SpawnMinion(position : Vector) : bool {
		var golemNPC 	: CNewNPC;
		var aiTree 		: CAIFollowSideBySideAction;
		var behId 		: int;
		var depotPath 	: String;
		var servants    : array<CEntity>;
		var actor    	: CActor;
		var num 		: int;

		// get number of alive servants
		theGame.GetEntitiesByTag('NR_Servant', servants);
		for (i = 0; i < servants.Size(); i += 1) {
			actor = (CActor)servants[i];
			if (actor && actor.IsAlive()) {
				num += 1;
			}
		}

		depotPath = map[sign].getS("entity_" + IntToString(num) + "_" + ENR_MAToName(actionType), "quests/part_3/quest_files/q501_eredin/characters/q501_wild_hunt_tier_1.w2ent");
		entityTemplate = (CEntityTemplate)LoadResourceAsync( depotPath, true );

		// use fx pos
		golemNPC = (CNewNPC)theGame.CreateEntity(entityTemplate, position, rot);
		if (!golemNPC) {
			NRE("SpawnMinion: golemNPC is invalid, depotPath = " + depotPath + ", template = " + entityTemplate);
			return false;
		}

		NR_AdjustMinionLevel( golemNPC, 1 );
		golemNPC.AddTag('NR_Servant');
		golemNPC.SetTemporaryAttitudeGroup( 'player', AGP_Default );
		golemNPC.SetAttitude( thePlayer, AIA_Friendly ); // shouldn't become hostile on accident
		// wave_ effect ?

		if (s_follower) {
			// Make follower
			aiTree = new CAIFollowSideBySideAction in golemNPC; // Initialize follower behavior
			aiTree.OnCreated(); // Once we're done initializing behavior tree
			aiTree.params.moveType = MT_Walk;
			behId = golemNPC.ForceAIBehavior( aiTree, BTAP_AboveEmergency );
			golemEntitiesBehIds.PushBack(behId);
		}

		golemEntities.PushBack(golemNPC);
		return true;
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
		var golemPositions 			: array<Vector>;
		var dummyEntity				: CEntity;
		var newPos, normalCollision : Vector;
		var i 						: int;
		var super_ret, ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false, scriptedPerform);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );

		for ( i = 0; i < s_minionCount; i += 1 ) {
			// randomize position
			pos = pos + VecRingRand(2.f, 4.f);
			// check where physics obstacle if needed
			if (theGame.GetWorld().StaticTrace(thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f + Vector(0,0,1.5f), pos, newPos, normalCollision, standartCollisions))
			{
				pos = newPos;
			}
			golemPositions.PushBack(pos);

			dummyEntity = (CEntity)theGame.CreateEntity(entityTemplate, pos, rot);
			if (!dummyEntity) {
				NRD("golem_fx_entity is invalid.");
				continue;
			}
			ret = dummyEntity.PlayEffect(m_fxNameMain);
			NRD("golem_fx_entity: PlayEffect (" + m_fxNameMain + ") = " + ret);
			dummyEntity.DestroyAfter(5.f);
			Sleep(0.1f);
		}

		Sleep(0.1f);

		for ( i = 0; i < s_minionCount; i += 1 ) {
			ret = SpawnMinion(golemPositions[i]);
			if ( !ret ) {
				return OnPerformed(false, scriptedPerform);
			}
			Sleep(0.1f);
		}
		GotoState('Active');

		return OnPerformed(true, scriptedPerform);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
	}

	latent function SpawnFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(actionType);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorWhite:
				return 'spawn_white';
			case ENR_ColorYellow:
				return 'spawn_yellow';
			case ENR_ColorOrange:
				return 'spawn_orange';
			case ENR_ColorRed:
				return 'spawn_red';
			case ENR_ColorPink:
				return 'spawn_pink';
			case ENR_ColorBlue:
				return 'spawn_blue';
			case ENR_ColorSeagreen:
				return 'spawn_seagreen';
			case ENR_ColorGreen:
				return 'spawn_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorViolet:
			default:
				return 'spawn_violet';
		}
	}
}

state Active in NR_MagicSpecialServant {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{
		NRD("Active: OnEnterState.");
		startTime = theGame.GetEngineTimeAsSeconds();
		parent.inPostState = true;
		MainLoop();		
	}

	entry function MainLoop() {
		Sleep( parent.s_lifetime );
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}

	event OnLeaveState( nextStateName : name )
	{
		var i : int;
		// cancel following player
		if (parent.s_follower) {
			for ( i = 0; i < parent.s_minionCount; i += 1 ) {
				parent.golemEntities[i].CancelAIBehavior(parent.golemEntitiesBehIds[i]);
			}
		}
		NRD("Active: OnLeaveState.");
	}
}

state Stop in NR_MagicSpecialServant {
	event OnEnterState( prevStateName : name )
	{
		NRD("Stop: OnEnterState.");
		parent.inPostState = true;
		Stop();
		parent.inPostState = false;
	}

	entry function Stop() {
		var i : int;

		for ( i = 0; i < parent.s_minionCount; i += 1 ) {
			Sleep(0.1f);
			parent.golemEntities[i].Kill('NR_MagicSpecialServant', true);
		}
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("Stop: OnLeaveState.");
		// can be removed from cached/cursed actions TODO CHECK
		parent.inPostState = false;
	}
}

state Cursed in NR_MagicSpecialServant {
	event OnEnterState( prevStateName : name )
	{
		NRD("Cursed: OnEnterState.");
		parent.inPostState = true;
		Curse();
	}

	entry function Curse() {
		var i : int;

		Sleep(0.5f);
		for ( i = 0; i < parent.s_minionCount; i += 1 ) {
			Sleep(0.1f);
			parent.golemEntities[i].ResetTemporaryAttitudeGroup(AGP_Default);
			parent.golemEntities[i].SetAttitude( thePlayer, AIA_Hostile );
		}

		Sleep( parent.s_lifetime * 0.5f );
		parent.StopAction();
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("Cursed: OnLeaveState.");
	}
}
