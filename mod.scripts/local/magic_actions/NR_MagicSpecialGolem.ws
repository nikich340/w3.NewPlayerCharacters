class NR_MagicSpecialGolem extends NR_MagicAction {
	var golemEntities 		: array<CNewNPC>;
	var golemsAmount 		: int;
	default actionType 		= ENR_SpecialGolem;
	default golemsAmount 	= 1;
	
	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 0);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			sceneInputs.PushBack(11);
			sceneInputs.PushBack(12);
			sceneInputs.PushBack(13);
			PlayScene( sceneInputs );
		}

		return true;
	}

	latent function OnPrepare() : bool {
		var i 			: int;

		super.OnPrepare();

		entityTemplate = (CEntityTemplate)LoadResourceAsync( 'nr_golem_spawn_fx' );
		dummyEntity = (CEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!dummyEntity) {
			NRE("golem_fx_entity is invalid.");
			return OnPrepared(false);
		}

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var golemNPC 				: CNewNPC;
		var golemPositions 			: array<Vector>;
		var dummyEntity				: CEntity;
		var newPos, normalCollision : Vector;
		var aiTree 					: CAIFollowSideBySideAction;
		var i 						: int;
		var    			  depotPath : String;
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		for ( i = 1; i <= golemsAmount; i += 1 ) {
			// randomize position
			pos = pos + VecRingRand(1.f, 3.f);
			// check where physics obstacle if needed
			if (theGame.GetWorld().StaticTrace(thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f + Vector(0,0,1.5f), pos, newPos, normalCollision, standartCollisions))
			{
				pos = newPos;
			}
			golemPositions.PushBack(pos);

			m_fxNameMain = SpawnFxName();
			dummyEntity.PlayEffect(m_fxNameMain);
			dummyEntity.DestroyAfter(5.f);
		}

		Sleep(0.25f);

		for ( i = 1; i <= golemsAmount; i += 1 ) {
			depotPath = map[sign].getS("entity" + IntToString(i) + "_" + ENR_MAToName(actionType));
			entityTemplate = (CEntityTemplate)LoadResourceAsync( depotPath, true );

			// use fx pos
			golemNPC = (CNewNPC)theGame.CreateEntity(entityTemplate, golemPositions[i - 1], rot);
			if (!golemNPC) {
				NRE("golem_entity is invalid.");
				return OnPerformed(false);
			}

			NR_AdjustMinionLevel( golemNPC, 1 );
			golemNPC.SetTemporaryAttitudeGroup( 'player', AGP_Default );
			golemNPC.SetAttitude( thePlayer, AIA_Friendly ); // shouldn't become hostile on accident
			// TODO: Hostile with some chance?
			// TODO: Hostile after some time?
			// TODO: Dies after some time?
			// wave_ effect ?
			// TODO :D call on thePlayer.OnSpawnHorse()
			///golemNPC.DestroyAfter(60.f);

			// Follower
			aiTree = new CAIFollowSideBySideAction in golemNPC; // Initialize follower behavior
			aiTree.OnCreated(); // Once we're done initializing behavior tree
			aiTree.params.moveType = MT_Walk;
			golemNPC.ForceAIBehavior( aiTree, BTAP_AboveEmergency );
		}
		
		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
	}

	latent function SpawnFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_SpecialAbstract);

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
