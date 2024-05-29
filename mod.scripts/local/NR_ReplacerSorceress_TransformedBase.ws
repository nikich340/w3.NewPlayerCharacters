state NR_TransformedBase in NR_ReplacerSorceress extends Base {
	var transformNPC 	: CActor;
	var MAC				: CMovingPhysicalAgentComponent;
	var movementAdjustor: CMovementAdjustor;
	var collisionObstaclesGround : array<name>;
	var isTransformActive : bool;

	var i, j 			: int;
	var blockedActions 	: array<EInputActionBlock>;
	default isTransformActive = true;

	event OnEnterState( prevStateName : name )
	{
		// Pass to base class
		super.OnEnterState(prevStateName);
		theInput.SetContext( 'Exploration' );

		transformNPC = theGame.GetActorByTag('NR_TRANSFORM_NPC');
		if (!transformNPC) {
			NR_Error("Leaving NR_Transformed: null transformNPC!");
			GotoState('Exploration');
		}
		MAC = (CMovingPhysicalAgentComponent)transformNPC.GetMovingAgentComponent();
		movementAdjustor = MAC.GetMovementAdjustor();

		virtual_parent.SetPlayerCombatStance( PCS_Normal, true );
		theGame.GetGuiManager().DisableHudHoldIndicator();
		parent.RemoveBuffImmunity_AllCritical('Swimming');
		
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetSwimming( false );
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetDiving( false );
		// ((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetTerrainInfluence(0.f);
		// ((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SnapToNavigableSpace(false);
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetAnimatedMovement(true);
		// ((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetGravity(false);

		parent.SetOrientationTarget( OT_Player );
		parent.ClearCustomOrientationInfoStack();
		// Force AI
		parent.SetCombatIdleStance( 1.f );
		parent.OnCombatActionEndComplete();
		parent.RaiseForceEvent( 'ForceIdle' );
		parent.SetBIsInputAllowed(true, 'ExplorationInit');

		blockedActions.PushBack( EIAB_Signs );
		blockedActions.PushBack( EIAB_DrawWeapon );
		blockedActions.PushBack( EIAB_Sprint );
		blockedActions.PushBack( EIAB_OpenInventory );
		blockedActions.PushBack( EIAB_RadialMenu );
		blockedActions.PushBack( EIAB_CallHorse );
		blockedActions.PushBack( EIAB_Fists );
		blockedActions.PushBack( EIAB_Roll );
		blockedActions.PushBack( EIAB_InteractionAction );
		blockedActions.PushBack( EIAB_ThrowBomb );
		blockedActions.PushBack( EIAB_Interactions );
		blockedActions.PushBack( EIAB_Dodge );
		blockedActions.PushBack( EIAB_SwordAttack );
		blockedActions.PushBack( EIAB_Parry );
		blockedActions.PushBack( EIAB_LightAttacks );
		blockedActions.PushBack( EIAB_HeavyAttacks );
		blockedActions.PushBack( EIAB_QuickSlots );
		blockedActions.PushBack( EIAB_Crossbow );
		blockedActions.PushBack( EIAB_UsableItem );
		blockedActions.PushBack( EIAB_Climb );
		blockedActions.PushBack( EIAB_Slide );
		blockedActions.PushBack( EIAB_MountVehicle );
		blockedActions.PushBack( EIAB_InteractionContainers );
		blockedActions.PushBack( EIAB_SpecialAttackLight );
		blockedActions.PushBack( EIAB_SpecialAttackHeavy );
		blockedActions.PushBack( EIAB_OpenGwint );
		blockedActions.PushBack( EIAB_OpenMeditation );

		// JUMP & ATTACK & WATER stuff
		collisionObstaclesGround.PushBack( 'Terrain' );
		collisionObstaclesGround.PushBack( 'Static' );
		collisionObstaclesGround.PushBack( 'Foliage' );
		collisionObstaclesGround.PushBack( 'Dynamic' );
		collisionObstaclesGround.PushBack( 'Corpse' );
		collisionObstaclesGround.PushBack( 'Destructible' );
		// collisionObstaclesGround.PushBack( 'Ragdoll' );
		collisionObstaclesGround.PushBack( 'RigidBody' );
		collisionObstaclesGround.PushBack( 'Platforms' );
		collisionObstaclesGround.PushBack( 'Boat' );
		collisionObstaclesGround.PushBack( 'BoatDocking' );
		collisionObstaclesGround.PushBack( 'Water' );

		// ENABLE PUPPET
		for (i = 0; i < blockedActions.Size(); i += 1) {
			parent.BlockAction( blockedActions[i], 'NR_TransformedBase' );
		}
		TooglePlayerPotency(false);
		parent.magicManager.UpdateMagicControlHints( thePlayer.GetCurrentStateName() );
	}

	function TooglePlayerPotency( enable : bool ) {
		thePlayer.EnableStaticCollisions(enable);
		thePlayer.EnableDynamicCollisions(enable);
		thePlayer.EnableCharacterCollisions(enable);
		thePlayer.EnableCollisions(enable);
		thePlayer.EnablePhysicalMovement(enable);
		thePlayer.SetGameplayVisibility(enable);
		thePlayer.SetVisibility(enable);
		thePlayer.SetManualControl(enable, enable);
		
		if (enable) {
			thePlayer.ResetTemporaryAttitudeGroup( AGP_Default );
		} else {
			thePlayer.SetTemporaryAttitudeGroup('animals_peacefull', AGP_Default);  // q104_avallach_friendly_to_all?
		}
	}

	event OnLeaveState( nextStateName : name )
	{	
		// DISABLE PUPET
		TooglePlayerPotency(true);
		for (i = 0; i < blockedActions.Size(); i += 1) {
			parent.UnblockAction( blockedActions[i], 'NR_TransformedBase' );
		}
		// ((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetTerrainInfluence(0.4f);
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetAnimatedMovement(false);
		// ((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetGravity(true);

		// Pass to base class
		super.OnLeaveState(nextStateName);
		parent.magicManager.UpdateMagicControlHints( nextStateName );
		NR_Debug("NR_TransformedBase: go to: " + nextStateName);
		///theInput.RestoreContext('Exploration', true);
	}

	// TODO: Check why it here?
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		virtual_parent.OnBlockingSceneStarted( scene );
		NR_Notify("NR_Transformed: OnBlockingSceneStarted: " + scene);
	}

	// TODO: Check why it here?
	event OnBlockingSceneStarted_OnIntroCutscene( scene: CStoryScene )
	{
		virtual_parent.OnBlockingSceneStarted_OnIntroCutscene( scene );
		NR_Notify("NR_Transformed: OnBlockingSceneStarted_OnIntroCutscene: " + scene);
	}

	// TODO: Check why it here?
	public function SetupCombatAction( action : EBufferActionType, stage : EButtonStage )
	{
		NR_Debug("NR_Transformed: SetupCombatAction: " + action + ", stage: " + stage);
		virtual_parent.SetupCombatAction(action, stage);
	}

	public function NR_IsTransformed() : bool {
		return isTransformActive;
	}
}
