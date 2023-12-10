statemachine class NR_MagicSpecialServant extends NR_MagicSpecialAction {
	var servantEntities 		: array<CNewNPC>;
	var servantEntitiesBehIds 	: array<int>;
	var servantTemplates 		: array<CEntityTemplate>;
	var s_follower 		: bool;
	var s_servantCount 	: int;
	default actionType 		= ENR_SpecialServant;
	default actionSubtype = ENR_SpecialAbstract;
	
	latent function OnInit() : bool {
		sceneInputs.PushBack(11);
		sceneInputs.PushBack(12);
		sceneInputs.PushBack(13);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		switch (newLevel) {
			case 1:
				ActionAbilityUnlock("barghest");
				break;
			case 2:
				ActionAbilityUnlock("endriaga");
				break;
			case 3:
				ActionAbilityUnlock("arachnomorph");
				break;
			case 4:
				ActionAbilityUnlock("Followers");
				break;
			case 5:
				ActionAbilityUnlock("arachas");
				break;
			case 6:
				ActionAbilityUnlock("TwoServants");
				break;
			case 7:
				ActionAbilityUnlock("gargoyle");
				break;
			case 8:
				ActionAbilityUnlock("earth_elemental");
				break;
			case 9:
				ActionAbilityUnlock("ice_elemental");
				break;
			case 10:
				ActionAbilityUnlock("fire_elemental");
				break;
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		var i 			: int;
		var template 	: CEntityTemplate;
		var servantName : name;
		var depotPath 	: String;

		super.OnPrepare();
		s_follower = IsActionAbilityUnlocked("Followers");
		s_servantCount = 1;
		if (IsActionAbilityUnlocked("TwoServants")) {
			s_servantCount += 1;
		}

		entityTemplate = (CEntityTemplate)LoadResourceAsync( 'nr_golem_spawn_fx' );
		m_fxNameMain = SpawnFxName();
		for (i = 0; i < s_servantCount; i += 1) {
			servantName = map[sign].getN("entity_" + IntToString(i) + "_" + ENR_MAToName(actionType), 'wild_hunt_hound');
			depotPath = ServantDepotPath(servantName);
			template = (CEntityTemplate)LoadResourceAsync( depotPath, true );
			NR_Debug("Loading servant[" + i + "] = " + template);
			servantTemplates.PushBack(template);
		}

		return OnPrepared(true);
	}

	latent function SpawnMinion(position : Vector, template : CEntityTemplate) : bool {
		var golemNPC 	: CNewNPC;
		var aiTree 		: CAIFollowSideBySideAction;
		var behId 		: int;
		var servants    : array<CEntity>;
		var actor    	: CActor;
		var num 		: int;

		// get number of alive servants
		//theGame.GetEntitiesByTag('NR_Servant', servants);
		//num = 0;
		//for (i = 0; i < servants.Size(); i += 1) {
		//	actor = (CActor)servants[i];
		//	if (actor && actor.IsAlive()) {
		//		num += 1;
		//	}
		//}

		// use fx pos
		golemNPC = (CNewNPC)theGame.CreateEntity(template, position, rot);
		if (!golemNPC) {
			NR_Error("SpawnMinion: golemNPC is invalid, template = " + template);
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
			servantEntitiesBehIds.PushBack(behId);
		}

		servantEntities.PushBack(golemNPC);
		return true;
	}

	latent function OnPerform() : bool {
		var golemPositions 			: array<Vector>;
		var dummyEntity				: CEntity;
		var newPos, normalCollision : Vector;
		var i 						: int;
		var super_ret, ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		if (IsInSetupScene()) {
			pos = MidPosInScene(/*far*/ false);
			s_lifetime = 5.f;
		} else {
			NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		}

		for ( i = 0; i < s_servantCount; i += 1 ) {
			// randomize position
			if (IsInSetupScene())
				pos = pos + VecRingRand(0.5f, 1.f);
			else
				pos = pos + VecRingRand(1.f, 3.f);
			// check where physics obstacle if needed
			if (theGame.GetWorld().StaticTrace(thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f + Vector(0,0,1.5f), pos, newPos, normalCollision, standartCollisions))
			{
				pos = newPos;
			}
			golemPositions.PushBack(pos);

			dummyEntity = (CEntity)theGame.CreateEntity(entityTemplate, pos, rot);
			if (!dummyEntity) {
				NR_Debug("golem_fx_entity is invalid.");
				continue;
			}
			ret = dummyEntity.PlayEffect(m_fxNameMain);
			NR_Debug("golem_fx_entity: PlayEffect (" + m_fxNameMain + ") = " + ret);
			dummyEntity.DestroyAfter(5.f);
			Sleep(0.1f);
		}

		Sleep(0.1f);

		for ( i = 0; i < s_servantCount; i += 1 ) {
			ret = SpawnMinion(golemPositions[i], servantTemplates[i]);
			if ( !ret ) {
				return OnPerformed(false);
			}
			Sleep(0.1f);
		}
		GotoState('Active');

		return OnPerformed(true);
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

	latent function ServantDepotPath(servantName : name) : String {
		switch (servantName) {
			case 'barghest':
				return "dlc/bob/data/living_world/enemy_templates/barghest_late.w2ent";
			case 'endriaga':
				return "dlc/bob/data/living_world/enemy_templates/endriaga_lvl2_mid.w2ent";
			case 'arachnomorph':
				return "dlc/bob/data/living_world/enemy_templates/spider_mid.w2ent";
			case 'arachas':
				return "quests/part_3/quest_files/q502_avallach/characters/q502_arachas.w2ent";
			case 'gargoyle':
				return "dlc/bob/data/quests/minor_quests/quest_files/mq7023_mutations/characters/mq7023_gargoyle_1.w2ent";
			case 'earth_elemental':
				return "dlc/dlcnewreplacers/data/entities/nr_q502_dao_fixed.w2ent";
			case 'ice_elemental':
				return "dlc/dlcnewreplacers/data/entities/nr_elemental_dao_lvl3__ice_fixed.w2ent";
			case 'fire_elemental':
				return "dlc/dlcnewreplacers/data/entities/nr_mq4006_ifryt_fixed.w2ent";
			case 'wild_hunt_hound':
			default:
				return "quests/part_3/quest_files/q501_eredin/characters/q501_wild_hunt_tier_1.w2ent";
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
		NR_Debug("Active: OnEnterState.");
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
			for ( i = 0; i < parent.s_servantCount; i += 1 ) {
				parent.servantEntities[i].CancelAIBehavior(parent.servantEntitiesBehIds[i]);
			}
		}
		NR_Debug("Active: OnLeaveState.");
	}
}

state Stop in NR_MagicSpecialServant {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Stop: OnEnterState.");
		parent.inPostState = true;
		RunStop();
		parent.inPostState = false;
	}

	entry function RunStop() {
		var i : int;

		for ( i = 0; i < parent.s_servantCount; i += 1 ) {
			Sleep(0.1f);
			parent.servantEntities[i].Kill('NR_MagicSpecialServant', true);
		}
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Stop: OnLeaveState.");
		// can be removed from cached/cursed actions TODO CHECK
		parent.inPostState = false;
	}
}

state Cursed in NR_MagicSpecialServant {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Cursed: OnEnterState.");
		parent.inPostState = true;
		RunCurse();
	}

	entry function RunCurse() {
		var i : int;

		Sleep(0.5f);
		for ( i = 0; i < parent.s_servantCount; i += 1 ) {
			Sleep(0.1f);
			parent.servantEntities[i].ResetTemporaryAttitudeGroup(AGP_Default);
			parent.servantEntities[i].SetAttitude( thePlayer, AIA_Hostile );
		}

		Sleep( parent.s_lifetime * 0.5f );
		parent.StopAction();
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Cursed: OnLeaveState.");
	}
}
