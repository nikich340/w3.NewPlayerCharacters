state NR_TransformedCat in NR_ReplacerSorceress extends NR_TransformedBase {
	var jumpEndEvent	: bool; 
	var attackEndEvent	: bool;

	var IN_WATER, IN_JUMP, IN_FALL, IN_ATTACK : bool;
	var breathingBubble : NR_BreathingBubble;

	event OnEnterState( prevStateName : name )
	{
		var bubbleTemplate : CEntityTemplate;
		// Pass to base class
		super.OnEnterState(prevStateName);
		NR_Debug("NR_TransformedCat.OnEnterState");
		
		// JUMP & ATTACK & WATER stuff
		bubbleTemplate = (CEntityTemplate)LoadResource("nr_breathing_bubble");
		breathingBubble = (NR_BreathingBubble)theGame.CreateEntity(bubbleTemplate, transformNPC.GetWorldPosition());
		if ( !breathingBubble ) {
			NR_Error("NR_Transformed: can't load bubble!");
		}
		if ( !breathingBubble.CreateAttachment(transformNPC, 'head') ) {
			NR_Error("NR_Transformed: can't attach bubble!");
		}
		breathingBubble.Init(0.25f, 2.f);
		transformNPC.AddAnimEventChildCallback(parent, 'JumpEnd', 'OnAnimEvent_JumpEnd');
		transformNPC.AddAnimEventChildCallback(parent, 'AttackEnd', 'OnAnimEvent_AttackEnd');

		CatLoop();
	}

	event OnAnimEvent_JumpEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		//NR_Debug("OnAnimEvent_JumpEnd: " + GetAnimNameFromEventAnimInfo(animInfo));
		jumpEndEvent = true;
	}
	event OnAnimEvent_AttackEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		//NR_Debug("OnAnimEvent_AttackEnd");
		attackEndEvent = true;
	}

	latent function CheckIsInWater() {
		if (MAC.GetSubmergeDepth() + MAC.GetCapsuleHeight() /*0.4f*/ < 0.f) {
			if (!IN_WATER) {
				breathingBubble.Activate();
				NR_Debug("GetCurrentGameState: " + theSound.GetCurrentGameState());
				NR_Debug("GetDefaultGameState: " + theSound.GetCurrentGameState());
				MAC.SetDiving(true);
				theSound.EnterGameState( ESGS_Underwater );
				theSound.SoundEvent("fx_underwater_on");
			}
			IN_WATER = true;
		} else {
			if (IN_WATER) {
				breathingBubble.Deactivate();
				NR_Debug("GetCurrentGameState: " + theSound.GetCurrentGameState());
				NR_Debug("GetDefaultGameState: " + theSound.GetCurrentGameState());
				MAC.SetDiving(false);
				theSound.LeaveGameState( ESGS_Underwater );
				thePlayer.SoundEvent("g_swim_emerge");
				theSound.SoundEvent("fx_underwater_off");
			}
			IN_WATER = false;
		}
	}

	latent function CheckIsInAir() {
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
				// NR_Debug("Suspecting in air: posZ = " + pos.Z + ", groundZ = " + groundZ);
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
			NR_Error("AttackLoop: can't raise beh event: Taunt");
			IN_ATTACK = false;
			return;
		}
		
		startTime = theGame.GetEngineTimeAsSeconds();

		NR_Debug("AttackLoop: alternate = " + alternate + ", start at: " + startTime);
		while (true) {
			SleepOneFrame();
			frameTime = theGame.GetEngineTimeAsSeconds();
			CheckIsInWater();

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
				NR_Error("JumpLoop: can't raise beh event: Jump");
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
		NR_Debug("JumpLoop: IN_JUMP = " + IN_JUMP + ", start at: " + startTime);

		while (true) {
			SleepOneFrame();
			frameTime = theGame.GetEngineTimeAsSeconds();

			CheckIsInWater();

			if (IN_JUMP) {
				if (jumpEndEvent) {
					maxPos = transformNPC.GetWorldPosition();
					IN_JUMP = false;
					IN_FALL = true;
				} else {
					if (frameTime - startTime > MAX_JUMP_DURATION * theGame.GetTimeScale() * transformNPC.GetAnimationTimeMultiplier()) {
						// hack hack...
						NR_Error("JumpLoop: HACK jumpEndEvent!");
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
					NR_Debug("JumpLoop: continue falling, posZ = " + pos.Z + ", groundZ = " + outPos.Z + ", moveZ = " + moveZ);
					// A bit of physics: U_max = sqrt(2P / c q S) = sqrt(2*40 / 1*1.29*0.1) = 600 m/s
					moveVec = VecNormalize2D( transformNPC.GetHeadingVector() );
					
					moveVec.Z = moveZ;
					movementAdjustor.AddOneFrameTranslationVelocity( moveVec );

					prevFrameTime = frameTime;
				} else {
					// stop falling
					// @ DAMAGE
					NR_Debug("JumpLoop: finish fall: dist = " + (maxPos.Z - pos.Z) + ", time = " + (frameTime - startTime) + " s");
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
	entry function CatLoop() {
    	var ticketAngle			: float;
    	var ticketAngles		: EulerAngles;
		var isRunPressed, isJumpPressed, isAttackPressed, isAttackAltPressed	: bool;
		var frameTime : float;
		var Editor_MovementSpeed, lEditor_MovementSpeed : float;
		var Editor_MovementRotation, lEditor_MovementRotation : float;
		var RL, FB, sumAngle, angleToReach, npcHeadingAngle, angleL, angleR : float;
		var numAxises : int;

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
			SleepOneFrame();

			frameTime = theGame.GetEngineTimeAsSeconds();
			if (!transformNPC.IsAlive()) {
				NR_Debug("transformCat is dead!");
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

			CheckIsInWater();
			if (isJumpPressed) {
				lEditor_MovementSpeed = 0.f;
				lEditor_MovementRotation = 0.f;
				
				// JumpLoop handles jumping until new input is allowed
				JumpLoop(true, isRunPressed);
				continue;
			}

			CheckIsInAir();
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
				NR_Debug("RL = " + RL + ", FB = " + FB + ", sumAngle = " + sumAngle + ", angleToReach = " + angleToReach + ", angleR = " + angleR + ", angleL = " + angleL);
			}
			//NR_Debug("camHeadingAngle = " + theCamera.GetCameraHeading() + ", angleToReach = " + angleToReach + ", npcHeadingAngle = " + npcHeadingAngle + ", angleR = " + angleR + ", angleL = " + angleL);

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

	event OnLeaveState( nextStateName : name )
	{
		breathingBubble.Deactivate();
		breathingBubble.DestroyAfter(1.f);
		transformNPC.RemoveAnimEventChildCallback(parent, 'JumpEnd');

		// Pass to base class
		super.OnLeaveState(nextStateName);
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
