class NR_MagicSpecialGolem extends NR_MagicAction {
	var golemEntities 		: array<CNewNPC>;
	var golemsAmount 		: int;
	default actionType 		= ENR_SpecialGolem;
	default actionName 	= 'AttackSpecialYrden';
	default golemsAmount 	= 3;
	
	latent function onPrepare() : bool {
		var i 			: int;

		super.onPrepare();

		resourceName = map[sign].getN("golem_fx_entity");
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

		return onPrepared(true);
	}
	latent function onPerform() : bool {
		var golemNPC 				: CNewNPC;
		var golemPositions 			: array<Vector>;
		var fxEntity				: CEntity;
		var newPos, normalCollision : Vector;
		var aiTree 					: CAIFollowSideBySideAction;
		var i 						: int;
		var super_ret : bool;
		super_ret = super.onPerform();
		if (!super_ret) {
			return onPerformed(false);
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

			fxEntity = (CEntity)theGame.CreateEntity(entityTemplate, pos, rot);
			if (!fxEntity) {
				NRE("golem_fx_entity is invalid.");
				return onPrepared(false);
			}
			fxEntity.PlayEffect('spawn');
			fxEntity.DestroyAfter(5.f);
		}

		Sleep(0.25f);

		for ( i = 1; i <= golemsAmount; i += 1 ) {
			resourceName = map[sign].getN( "golem_entity" + IntToString(i) );
			entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

			// use fx pos
			golemNPC = (CNewNPC)theGame.CreateEntity(entityTemplate, golemPositions[i - 1], rot);
			if (!golemNPC) {
				NRE("golem_entity is invalid.");
				return onPerformed(false);
			}

			golemNPC.SetTemporaryAttitudeGroup( 'player', AGP_Default );
			golemNPC.SetAttitude( thePlayer, AIA_Friendly );
			// TODO: Hostile with some chance?
			// TODO: Hostile after some time?
			// TODO: Dies after some time?
			// wave_ effect ?
			// TODO :D call on thePlayer.OnSpawnHorse()
			///golemNPC.DestroyAfter(60.f);

			// Follower
			aiTree = new CAIFollowSideBySideAction in golemNPC; // Initialize follower behavior
			aiTree.OnCreated(); // Once we're done initializing behavior tree
			aiTree.params.moveType = MT_Sprint;
			golemNPC.ForceAIBehavior( aiTree, BTAP_AboveEmergency2 );
		}
		
		return onPerformed(true);
	}
	latent function BreakAction() {
		if (isPerformed) // golem is independent from caster
			return;

		super.BreakAction();
	}
}
