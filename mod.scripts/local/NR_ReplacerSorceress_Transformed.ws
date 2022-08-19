state NR_Transformed in NR_ReplacerSorceress extends Base {
	var transformNPC 	: CNewNPC;
	var MAC				: CMovingPhysicalAgentComponent; 
	var movementAdjustor: CMovementAdjustor; 
	var jumpEndEvent	: bool; 
	var attackEndEvent	: bool; 
	var collisionObstaclesGround : array<name>;

	var IN_WATER, IN_JUMP, IN_FALL, IN_ATTACK : bool;
	var breathingBubble : NR_BreathingBubble;
	var i, j 			: int;
	var blockedActions 	: array<EInputActionBlock>;

	event OnEnterState( prevStateName : name )
	{
		var bubbleTemplate : CEntityTemplate;
		// Pass to base class
		super.OnEnterState(prevStateName);
		theInput.SetContext( 'Exploration' );

		transformNPC = theGame.GetNPCByTag('NR_TRANSFORM_NPC');
		if (!transformNPC) {
			NRE("Leaving NR_Transformed: null transformNPC!");
			GotoState('Exploration');
		}
		MAC = (CMovingPhysicalAgentComponent)transformNPC.GetMovingAgentComponent();
		movementAdjustor = MAC.GetMovementAdjustor();

		virtual_parent.SetPlayerCombatStance( PCS_Normal, true );
		theGame.GetGuiManager().DisableHudHoldIndicator();
		parent.RemoveBuffImmunity_AllCritical('Swimming');
		
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetSwimming( false );
		((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).SetDiving( false );
		((CMovingPhysicalAgentComponent) parent.GetMovingAgentComponent()).SetTerrainInfluence(0.f);

		parent.SetOrientationTarget( OT_Player );
		parent.ClearCustomOrientationInfoStack();
		// Force AI
		parent.SetCombatIdleStance( 1.f );
		parent.OnCombatActionEndComplete();
		parent.RaiseForceEvent( 'ForceIdle' );
		parent.SetBIsInputAllowed(true, 'ExplorationInit');

		//blockedActions.PushBack( EIAB_Signs );
		blockedActions.PushBack( EIAB_DrawWeapon );
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
		//blockedActions.PushBack( EIAB_OpenMeditation );

		// JUMP & ATTACK & WATER stuff
		bubbleTemplate = (CEntityTemplate)LoadResource("nr_breathing_bubble");
		breathingBubble = (NR_BreathingBubble)theGame.CreateEntity(bubbleTemplate, transformNPC.GetWorldPosition());
		if ( !breathingBubble ) {
			NRE("NR_Transformed: can't load bubble!");
		}
		if ( !breathingBubble.CreateAttachment(transformNPC, 'head') ) {
			NRE("NR_Transformed: can't attach bubble!");
		}
		breathingBubble.Init(0.25f, 2.f);

		transformNPC.AddAnimEventChildCallback(parent, 'JumpEnd', 'OnAnimEvent_JumpEnd');
		transformNPC.AddAnimEventChildCallback(parent, 'AttackEnd', 'OnAnimEvent_AttackEnd');
		collisionObstaclesGround.PushBack( 'Terrain' );
		collisionObstaclesGround.PushBack( 'Static' );
		collisionObstaclesGround.PushBack( 'Foliage' );
		collisionObstaclesGround.PushBack( 'Dynamic' );
		collisionObstaclesGround.PushBack( 'Destructible' );
		collisionObstaclesGround.PushBack( 'RigidBody' );
		collisionObstaclesGround.PushBack( 'Platforms' );
		collisionObstaclesGround.PushBack( 'Boat' );
		collisionObstaclesGround.PushBack( 'BoatDocking' );
		// ENABLE PUPPET
		for (i = 0; i < blockedActions.Size(); i += 1) {
			parent.BlockAction( blockedActions[i], 'NR_Transformed' );
		}
		TooglePlayerPotency(false);

		MainLoop();
	}

	event OnAnimEvent_JumpEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		//NRD("OnAnimEvent_JumpEnd: " + GetAnimNameFromEventAnimInfo(animInfo));
		jumpEndEvent = true;
	}
	event OnAnimEvent_AttackEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		//NRD("OnAnimEvent_AttackEnd");
		attackEndEvent = true;
	}

	latent function CheckInWater() {
		if (MAC.GetSubmergeDepth() + /* MAC.GetCapsuleHeight()*/ 0.4f < 0.f) {
			if (!IN_WATER) {
				breathingBubble.Activate();
				NRD("GetCurrentGameState: " + theSound.GetCurrentGameState());
				NRD("GetDefaultGameState: " + theSound.GetCurrentGameState());
				MAC.SetDiving(true);
				theSound.NR_EnterGameState( ESGS_Underwater );
				theSound.SoundEvent("fx_underwater_on");
			}
			IN_WATER = true;
		} else {
			if (IN_WATER) {
				breathingBubble.Deactivate();
				NRD("GetCurrentGameState: " + theSound.GetCurrentGameState());
				NRD("GetDefaultGameState: " + theSound.GetCurrentGameState());
				MAC.SetDiving(false);
				theSound.LeaveGameState( ESGS_Underwater );
				thePlayer.SoundEvent("g_swim_emerge");
				theSound.SoundEvent("fx_underwater_off");
			}
			IN_WATER = false;
		}
	}
	latent function CheckInAir() {
		var world : CWorld;
		var pos, outPos, outNormal : Vector;
		var groundZ, outZ : float;

		// Check Falling
		world = theGame.GetWorld();
		pos = transformNPC.GetWorldPosition();
		outPos = pos;
		groundZ = pos.Z;

		// use navdata - fast
		if ( theGame.GetWorld().NavigationComputeZ( pos, pos.Z - 128.f, pos.Z + 1.f, outZ ) ) {
			groundZ = outZ;
			outPos.Z = outZ;
		}

		// try to make more precise
		if ( theGame.GetWorld().PhysicsCorrectZ( outPos, outZ ) ) {
			groundZ = outZ;
			outPos.Z = outZ;
		}

		// suspecting
		if (pos.Z > groundZ + 0.25f) {
			// extra check - raycast with radius - slow?
			if ( theGame.GetWorld().SweepTest( pos + Vector(0, 0, 1.f), pos - Vector(0, 0, 128.f), 0.1f, outPos, outNormal, collisionObstaclesGround ) ) {
				groundZ = outPos.Z;
			}

			if (pos.Z > groundZ + 0.25f) {
				// NRD("Suspecting in air: posZ = " + pos.Z + ", groundZ = " + groundZ);
				IN_FALL = true;
				return;
			}
		}
		IN_FALL = false;
	}
	latent function AttackLoop(alternate : bool) {
		var startTime, frameTime : float;
		var MAX_ATTACK_DURATION : float;

		MAX_ATTACK_DURATION = 3.f;
		IN_ATTACK = true;
		attackEndEvent = false;

		if ( !transformNPC.GetRootAnimatedComponent().RaiseBehaviorEvent( 'Taunt' ) ) {
			NRE("AttackLoop: can't raise beh event: Taunt");
			IN_ATTACK = false;
			return;
		}
		
		startTime = theGame.GetEngineTimeAsSeconds();

		NRD("AttackLoop: alternate = " + alternate + ", start at: " + startTime);
		while (true) {
			SleepOneFrame();
			frameTime = theGame.GetEngineTimeAsSeconds();
			CheckInWater();

			if (attackEndEvent || frameTime - startTime > MAX_ATTACK_DURATION) {
				IN_ATTACK = false;
				return;
			}
		}
	}
	latent function JumpLoop(inJump : bool, isRunning : bool) {
		var MAX_JUMP_DURATION : float;
		var startTime, frameTime, prevFrameTime : float;
		var groundZ : float;
		var progressZ : float;
		var moveZ_perSec	: float;
		var moveZ 			: float;
		var moveVec 		: Vector;
		var pos, maxPos 	: Vector;
		var outPos, outNormal : Vector;
		var ticket						: SMovementAdjustmentRequestTicket;

		MAX_JUMP_DURATION = 0.5f;
		moveZ = 0.f;
		moveZ_perSec = -50.f;

		transformNPC.SetBehaviorVariable('Editor_MovementRotation', 0.f);
		transformNPC.SetBehaviorVariable('Editor_MovementSpeed', 0.f);
		MAC.SetAnimatedMovement( true ); // set simulated
		
		if (inJump) {
			transformNPC.SetBehaviorVariable( 'NR_SmallJump', (float)isRunning );
			if ( !transformNPC.GetRootAnimatedComponent().RaiseBehaviorEvent( 'Jump' ) ) {
				NRE("JumpLoop: can't raise beh event: Jump");
				IN_JUMP = false;
				MAC.SetAnimatedMovement( false ); // set animated
				return;
			}
			
			IN_JUMP = true;
		} else {
			maxPos = transformNPC.GetWorldPosition();
			IN_FALL = true;
		}
		jumpEndEvent = false;

		startTime = theGame.GetEngineTimeAsSeconds();
		prevFrameTime = theGame.GetEngineTimeAsSeconds();
		NRD("JumpLoop: IN_JUMP = " + IN_JUMP + ", start at: " + startTime);

		while (true) {
			SleepOneFrame();
			frameTime = theGame.GetEngineTimeAsSeconds();

			CheckInWater();

			if (IN_JUMP) {
				if (jumpEndEvent) {
					maxPos = transformNPC.GetWorldPosition();
					IN_JUMP = false;
					IN_FALL = true;
				} else {
					if (frameTime - startTime > MAX_JUMP_DURATION * theGame.GetTimeScale() * transformNPC.GetAnimationTimeMultiplier()) {
						// hack hack...
						NRE("JumpLoop: HACK jumpEndEvent!");
						jumpEndEvent = true;
					}
					prevFrameTime = frameTime;
					continue;
				}
			}
			// CAT capsule: Radius: 0.100000, Height: 0.800000

			if (IN_FALL) {
				pos = transformNPC.GetWorldPosition();
				// raycast with radius
				theGame.GetWorld().SweepTest( pos + Vector(0, 0, 1.f), pos - Vector(0, 0, 128.f), 0.1f, outPos, outNormal, collisionObstaclesGround );
				
				if (pos.Z - outPos.Z > 0.1f && MAC.GetCollisionDataCount() == 0) {
					
					if (IN_WATER)   // don't ask me about these values.. empiric
						moveZ = MaxF(-5.f, moveZ + moveZ_perSec * (frameTime - prevFrameTime) * 0.25f);
					else
						moveZ = MaxF(-20.f, moveZ + moveZ_perSec * (frameTime - prevFrameTime));
					NRD("JumpLoop: continue falling, posZ = " + pos.Z + ", groundZ = " + outPos.Z + ", moveZ = " + moveZ);
					// A bit of physics: U_max = sqrt(2P / c q S) = sqrt(2*40 / 1*1.29*0.1) = 600 m/s
					moveVec = VecNormalize2D( transformNPC.GetHeadingVector() );
					
					moveVec.Z = moveZ;
					movementAdjustor.AddOneFrameTranslationVelocity( moveVec );

					prevFrameTime = frameTime;
				} else {
					// stop falling
					// @ DAMAGE
					NRD("JumpLoop: finish fall: dist = " + (maxPos.Z - pos.Z) + ", time = " + (frameTime - startTime) + " s");
					MAC.SetAnimatedMovement( false ); // set animated

					ticket = movementAdjustor.CreateNewRequest( 'NR_TRANSFORM_Land_Adjustment' );
					//transformNPC.Teleport( pos );
					movementAdjustor.AdjustmentDuration( ticket, 0.2f );
					movementAdjustor.SlideTo( ticket, outPos );
					transformNPC.ApplyFallingDamage( maxPos.Z - pos.Z, IN_WATER );
					Sleep(0.2f);
					IN_FALL = false;
					return;
				}
			}
		}
	}
	entry function MainLoop() {
    	var ticketAngle			: float;
    	var ticketAngles		: EulerAngles;
		var isRunPressed, isJumpPressed, isAttackPressed, isAttackAltPressed	: bool;
		var frameTime : float;
		var Editor_MovementSpeed, lEditor_MovementSpeed : float;
		var Editor_MovementRotation, lEditor_MovementRotation : float;
		var RL, FB, sumAngle, angleToReach, npcHeadingAngle, angleL, angleR : float;
		var numAxises : int;

		var IN_WATER : bool;
		var pos, groundPos : Vector;
		var outPos, outNormal : Vector;
		var outZ, groundZ : float;

		var camera : CCustomCamera = theGame.GetGameCamera();		
		if (camera)
		{
			//camera.ChangePivotRotationController('Default');
			camera.ChangePivotPositionController('Default');
			camera.ChangePivotDistanceController('Default');
		}

		lEditor_MovementSpeed 		= 0.f;
		lEditor_MovementRotation 	= 0.f;

		while (true) {
			SleepOneFrame(); // in case something will do "continue"

			frameTime = theGame.GetEngineTimeAsSeconds();
			if (!transformNPC.IsAlive()) {
				thePlayer.Kill( 'NR_TransformNPC', true );
				break;
			}
			// ? CInputAxisDoubleTap
			isRunPressed = theInput.IsActionPressed( 'Sprint' );
			isJumpPressed = theInput.IsActionPressed( 'Jump' );
			isAttackPressed = theInput.IsActionPressed( 'AttackWithAlternateLight' );
			isAttackAltPressed = theInput.IsActionPressed( 'AttackWithAlternateHeavy' );

			FB = theInput.GetActionValue( 'GI_AxisLeftY' );
			RL = theInput.GetActionValue( 'GI_AxisLeftX' );

			CheckInWater();
			if (isJumpPressed) {
				lEditor_MovementSpeed = 0.f;
				lEditor_MovementRotation = 0.f;
				
				// JumpLoop handles jumping until new input is allowed
				JumpLoop(true, isRunPressed);
				continue;
			}

			CheckInAir();
			if (IN_FALL) {
				lEditor_MovementSpeed = 0.f;
				lEditor_MovementRotation = 0.f;
				
				// JumpLoop handles jumping until new input is allowed
				JumpLoop(false, isRunPressed);
			}


			if (isAttackPressed || isAttackAltPressed) {
				lEditor_MovementSpeed = 0.f;
				lEditor_MovementRotation = 0.f;
				transformNPC.SetBehaviorVariable('Editor_MovementRotation', lEditor_MovementRotation);
				transformNPC.SetBehaviorVariable('Editor_MovementSpeed', lEditor_MovementSpeed);
				// AttackLoop handles attacking until new input is allowed
				AttackLoop(isAttackAltPressed);
				continue;
			}

			sumAngle = 0.f;
			numAxises = 0;

			if (RL > 0.f) {
				sumAngle += 270.f;
				numAxises += 1;
			} else if (RL < 0.f) {
				sumAngle += 90.f;
				numAxises += 1;
			}

			if (FB > 0.f) {
				// otherwise Forward-Right (0 + 270) == Backward-Left (90 + 180)
				// 360 + 270 -> correct Forward-Right angle
				if (RL > 0.f) {
					sumAngle += 360.f;
				}
				numAxises += 1;
			} else if (FB < 0.f) {
				sumAngle += 180.f;
				numAxises += 1;
			}

			if (numAxises < 1) { 	// no button is pressed
				Editor_MovementSpeed = 0.f;
			} else {
				if (isRunPressed) { // shift is pressed
					Editor_MovementSpeed = 2.f;
				} else { 			// shift is NOT pressed
					Editor_MovementSpeed = 1.f;
				}
			}
			
			angleToReach = sumAngle / numAxises; // get resulting angle
			angleToReach = AngleNormalize( theCamera.GetCameraHeading() + angleToReach ); // make NPC-relative
			npcHeadingAngle = transformNPC.GetHeading();

			angleR = AngleNormalize( npcHeadingAngle - angleToReach ); // if rotate clockwise (Right)
			angleL = AngleNormalize( angleToReach - npcHeadingAngle );  // if rotate counterclockwise (Left)

			if (numAxises > 1) {
				NRD("RL = " + RL + ", FB = " + FB + ", sumAngle = " + sumAngle + ", angleToReach = " + angleToReach + ", angleR = " + angleR + ", angleL = " + angleL);
			}
			//NRD("camHeadingAngle = " + theCamera.GetCameraHeading() + ", angleToReach = " + angleToReach + ", npcHeadingAngle = " + npcHeadingAngle + ", angleR = " + angleR + ", angleL = " + angleL);

			if (MinF(angleR, angleL) < 30.f) { // if diff is small no need in rotating
				Editor_MovementRotation = 0.f;
				if (angleR < angleL) {
					ticketAngles.Yaw = -MinF(angleR * 75.f, 75.f); // 75 is empiric coefficient
					movementAdjustor.AddOneFrameRotationVelocity( ticketAngles );
				} else {
					ticketAngles.Yaw = MinF(angleL * 75.f, 75.f); // 75 is empiric coefficient
					movementAdjustor.AddOneFrameRotationVelocity( ticketAngles );
				}
			} else if (angleR < angleL) {
				Editor_MovementRotation = 1.f; // rotate Right
			} else {
				Editor_MovementRotation = -1.f; // rotate Left
			}

			if (lEditor_MovementRotation != Editor_MovementRotation) {
				transformNPC.SetBehaviorVariable('Editor_MovementRotation', Editor_MovementRotation);
				lEditor_MovementRotation = Editor_MovementRotation;
			}
			if (lEditor_MovementSpeed != Editor_MovementSpeed) {
				transformNPC.SetBehaviorVariable('Editor_MovementSpeed', Editor_MovementSpeed);
				lEditor_MovementSpeed = Editor_MovementSpeed;
			}
		}
	}

	function TooglePlayerPotency( enable : bool ) {
		thePlayer.EnableStaticCollisions(enable);
		thePlayer.EnableDynamicCollisions(enable);
		thePlayer.EnableCharacterCollisions(enable);
		thePlayer.EnableCollisions(enable);
		thePlayer.SetGameplayVisibility(enable);
		thePlayer.SetVisibility(enable);
		thePlayer.SetManualControl(enable, enable);
		
		if (enable)
			thePlayer.SetTemporaryAttitudeGroup('animals_peacefull', AGP_Default);
		else
			thePlayer.ResetTemporaryAttitudeGroup( AGP_Default );
	}

	event OnLeaveState( nextStateName : name )
	{	
		// DISABLE PUPET
		TooglePlayerPotency(true);
		for (i = 0; i < blockedActions.Size(); i += 1) {
			parent.UnblockAction( blockedActions[i], 'NR_Transformed' );
		}
		((CMovingPhysicalAgentComponent) parent.GetMovingAgentComponent()).SetTerrainInfluence(0.4f);
		transformNPC.RemoveAnimEventChildCallback(parent, 'JumpEnd');

		// Pass to base class
		super.OnLeaveState(nextStateName);

		if( nextStateName == 'PlayerDialogScene') {
			NRD("NR_Transformed: TO SCENE!");
		}
		NRD("NR_Transformed: " + nextStateName);

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
		NRD("NR_Transformed: SetupCombatAction: " + action + ", stage: " + stage);
		virtual_parent.SetupCombatAction(action, stage);
	}

	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		// --- super.OnGameCameraTick(moveData, dt);

		// closer to cat
		moveData.pivotDistanceController.SetDesiredDistance( 1.2f );
		moveData.pivotPositionController.SetDesiredPosition( transformNPC.GetWorldPosition() );
		moveData.pivotPositionController.offsetZ = 0.4f;
		return true;
	}
}
