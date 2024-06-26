state NR_TransformedCrow in NR_ReplacerSorceress extends NR_TransformedBase {
	protected var transformedCamera : CStaticCamera;
	protected var RL, FB, inputX, inputY : float;
	protected var sweepTestBumped, inAttackAction : bool;
	protected var isRunPressed, isJumpPressed, isAttackPressed, isUsePressed, isPotion4Pressed : bool;
	protected var frameTime, attackCooldown, attackMaxCooldown : float;
	protected var forwardSpeed, forwardTargetSpeed, forwardMaxSpeed, forwardAccelerateInSec : float;
	protected var heightSpeed, heightTargetSpeed, heightMaxSpeed, heightAccelerateInSec : float;
	protected var rollAngle, rollTargetAngle, rollMaxAngle, rollChangeInSec : float;
	protected var yawAngleChange, yawAngleChangeMax, angleCamR, angleCamL, headingToTarget : float;
	protected var crowRotation, newCrowRotation : EulerAngles;
	protected var cameraPos, cameraVelocity, cameraTargetPos, crowPosition, oldCrowPosition, targetPos, moveVec, sweepTracePos, sweepTraceNormal : Vector;
	protected var cameraRot, cameraTargetRot : EulerAngles;
	protected var cameraInitTime, yawVelocity, pitchVelocity : float;
	protected var crowAnimComp : CAnimatedComponent;
	protected var crowBehState : name;
	protected var crowMovedInTick : bool;
	protected var attackTarget : CActor;
	protected var attackTargetBoneIndex : int;
	protected var attackDummyTemplate : CEntityTemplate;
	protected var world : CWorld;

	event OnEnterState( prevStateName : name )
	{
		// Pass to base class
		super.OnEnterState(prevStateName);
		NR_Info("NR_TransformedCrow.OnEnterState: " + transformNPC);
		MAC.SnapToNavigableSpace(false);
		MAC.SetAnimatedMovement(true);
		//MAC.SetSwimming(true);
		//MAC.SetDiving(true);
		MAC.SetGravity(false);
		MAC.EnableCollisionPrediction(false);

		transformNPC.EnablePhysicalMovement(false);
		transformNPC.EnableCharacterCollisions(false);
		transformNPC.EnableStaticCollisions(false);
		transformNPC.EnableDynamicCollisions(false);
		transformNPC.EnableCollisions(true);

		SetupCrowFly();
	}

	public function ApplyCrowBehStateIfNew(newStateName : name) {
		if (crowBehState != newStateName) {
			if (crowAnimComp.RaiseBehaviorEvent(newStateName)) {
				// NR_Debug("ApplyCrowBehStateIfNew: " + newStateName);
				crowBehState = newStateName;
			}
		}
	}

	entry function SetupCrowFly() {
		var entityTemplate : CEntityTemplate;

		frameTime = 0.0069f;
		attackCooldown = -1.f;
		attackMaxCooldown = 2.f;
		crowAnimComp = transformNPC.GetRootAnimatedComponent();
		entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_static_camera");
		cameraPos = theCamera.GetCameraPosition();
		cameraTargetPos = cameraPos;
		cameraRot = theCamera.GetCameraRotation();
		cameraRot.Pitch = AngleNormalize180( cameraRot.Pitch );
		cameraTargetRot = cameraRot;
		cameraInitTime = theGame.GetEngineTimeAsSeconds();
		transformedCamera = (CStaticCamera)theGame.CreateEntity( entityTemplate, cameraPos, cameraRot );
		transformedCamera.Run();

		forwardSpeed = 0.f;
		forwardTargetSpeed = 0.f;
		forwardAccelerateInSec = 25.f;
		forwardMaxSpeed = 12.5f;

		heightSpeed = 0.f;
		heightTargetSpeed = 0.f;
		heightMaxSpeed = 7.5f;
		heightAccelerateInSec = 5.f;

		rollAngle = 0.f;
		rollTargetAngle = 0.f;
		rollChangeInSec = 40.f;
		rollMaxAngle = 20.f;

		yawAngleChange = 0.f;
		yawAngleChangeMax = 90.f;

		attackDummyTemplate = (CEntityTemplate)LoadResourceAsync("nr_dummy_hit_fx");
		PreloadEffectForEntityTemplate(attackDummyTemplate, 'hit_electric_white');
		world = theGame.GetWorld();
		crowRotation = transformNPC.GetWorldRotation();
		crowPosition = transformNPC.GetWorldPosition();
		oldCrowPosition = crowPosition;
		theSound.SoundLoadBank("animals_crow.bnk", true);
		theSound.SoundLoadBank("physics_objects.bnk", true);

		ApplyCrowBehStateIfNew('FlyInPlace');
		transformNPC.PlayEffect('feathers');
		transformNPC.SoundEvent("animals_crow_call");

		parent.AddTimer( 'CrowLoopTimer', frameTime, true, false, TICK_PrePhysics );
		parent.AddTimer( 'UpdateStaticCameraTimer', frameTime, true, false, TICK_Main );
	}

	timer function CrowLoopTimer( deltaTime : float, id : int ) {
		var damage : W3DamageAction;
		var distSq : float;
		var attackDummyEntity : CEntity;

		// NR_Debug("CrowLoopTimer: delta = " + deltaTime + ", pos = " + VecToString(transformNPC.GetLocalPosition()) + ", rot = " + NR_EulerToString(transformNPC.GetLocalRotation()));
		UpdateInputValues();

		if (!transformNPC.IsAlive()) {
			// NR_Debug("transformCrow is dead!");
			thePlayer.Kill( 'NR_TransformNPC', true );
			parent.RemoveTimer('CrowLoopTimer');
			parent.RemoveTimer('UpdateStaticCameraTimer');
			return;
		}

		attackCooldown -= deltaTime;
		if (inAttackAction) {
			targetPos = attackTarget.GetBoneWorldPositionByIndex(attackTargetBoneIndex);
			distSq = VecDistanceSquared(crowPosition, targetPos);
			deltaTime *= 2.5f;
			if (distSq < SqrF(attackTarget.GetRadius())) {
				attackDummyEntity = theGame.CreateEntity(attackDummyTemplate, targetPos);
				attackDummyEntity.PlayEffect('hit_electric_white');
				attackDummyEntity.DestroyAfter(5.f);
				transformNPC.SoundEvent("phx_leszy_totem_destroy_hit");
				transformNPC.PlayEffect('feathers');

				damage = new W3DamageAction in this;
				damage.Initialize( thePlayer, attackTarget, thePlayer, thePlayer.GetName(), EHRT_Light, CPS_SpellPower, false, false, false, true );
				damage.AddEffectInfo(EET_Stagger, 1.f);
				damage.AddDamage( theGame.params.DAMAGE_NAME_SLASHING, attackTarget.GetMaxHealth() * 0.025f );
				damage.AddDamage( theGame.params.DAMAGE_NAME_SILVER, attackTarget.GetMaxHealth() * 0.025f );
				theGame.damageMgr.ProcessAction( damage );
				delete damage;

				// hit player too
				damage = new W3DamageAction in this;
				damage.Initialize( attackTarget, thePlayer, attackTarget, attackTarget.GetName(), EHRT_Light, CPS_AttackPower, false, false, false, true );
				damage.AddDamage( theGame.params.DAMAGE_NAME_PHYSICAL, thePlayer.GetMaxHealth() * 0.01f );
				theGame.damageMgr.ProcessAction( damage );
				delete damage;

				rollAngle = 0.f;
				inAttackAction = false;
				attackCooldown = attackMaxCooldown;
			} else if (!crowMovedInTick) {
				// cancel cause we bumped into smth?
				rollAngle = 0.f;
				inAttackAction = false;
				attackCooldown = attackMaxCooldown;
			}
		}

		if (isAttackPressed) {
			if (attackCooldown < 0.f) {
				attackTarget = parent.GetTarget();
				attackTargetBoneIndex = attackTarget.GetBoneIndex('head');
				if (attackTargetBoneIndex < 0) {
					attackTargetBoneIndex = attackTarget.GetBoneIndex('k_head_g');
					if (attackTargetBoneIndex < 0) {
						attackTargetBoneIndex = 0;
					}
				}
				targetPos = attackTarget.GetBoneWorldPositionByIndex(attackTargetBoneIndex);
				distSq = VecDistanceSquared(crowPosition, targetPos);

				if (attackTarget) {
					if (GetAttitudeBetween(thePlayer, attackTarget) == AIA_Friendly) {
						thePlayer.DisplayHudMessage(GetLocStringByKey("panel_hud_message_cant_attack_this_target"));
					} else {
						inAttackAction = true;
						ApplyCrowBehStateIfNew('GlideForward');
						transformNPC.SoundEvent("animals_crow_call");
					}
				}
			} else {
				theSound.SoundEvent("gui_inventory_overweighted");
			}
		}

		if (inAttackAction) {
			forwardTargetSpeed = forwardMaxSpeed;
		} else if (FB > 0.f) {
			forwardTargetSpeed = forwardMaxSpeed;
		} else {
			forwardTargetSpeed = 0.f;
		}

		// buttons have priority
		if (inAttackAction) {
			newCrowRotation = VecToRotation(targetPos - crowPosition);
			// 0.2f = full change
			crowRotation.Yaw = newCrowRotation.Yaw;
			crowRotation.Roll = LerpAngleF( deltaTime / 0.2f, crowRotation.Roll, newCrowRotation.Roll );
			crowRotation.Pitch = LerpAngleF( deltaTime / 0.2f, crowRotation.Pitch, newCrowRotation.Pitch );
		} else if (RL > 0.f) {
			rollTargetAngle = rollMaxAngle;
			yawAngleChange = -yawAngleChangeMax;
		} else if (RL < 0.f) {
			rollTargetAngle = -rollMaxAngle;
			yawAngleChange = yawAngleChangeMax;
		} else {
			angleCamR = AngleNormalize( transformNPC.GetHeading() - cameraRot.Yaw ); // if rotate clockwise (Right)
			angleCamL = AngleNormalize( cameraRot.Yaw - transformNPC.GetHeading() );
			if (MinF(angleCamR, angleCamL) < 1.f) {
				// too small delta, no need to correct
				rollTargetAngle = 0.f;
				yawAngleChange = 0.f;
			} else if (angleCamR < angleCamL) {
				// faster to rotate right
				rollTargetAngle = rollMaxAngle;
				yawAngleChange = -yawAngleChangeMax;
			} else {
				// faster to rotate left
				rollTargetAngle = -rollMaxAngle;
				yawAngleChange = yawAngleChangeMax;
			}
		}

		if (inAttackAction) {
			if (AbsF(crowPosition.Z - targetPos.Z) < 0.1f)
				heightTargetSpeed = 0;
			else if (crowPosition.Z < targetPos.Z)
				heightTargetSpeed = heightMaxSpeed;
			else if (crowPosition.Z > targetPos.Z)
				heightTargetSpeed = -heightMaxSpeed;
		} else if (isJumpPressed) {
			heightTargetSpeed = heightMaxSpeed;
		} else if (isUsePressed) {
			heightTargetSpeed = -heightMaxSpeed;
		} else {
			heightTargetSpeed = 0.f;
		}

		if (sweepTestBumped /*|| isPotion4Pressed*/) {
			forwardTargetSpeed *= 0.5f;
			rollTargetAngle *= 0.6f;
			yawAngleChange *= 0.6f;
			heightTargetSpeed *= 0.6f;
		} else if (isRunPressed) {
			forwardTargetSpeed *= 1.75f;
			rollTargetAngle *= 1.5f;
			yawAngleChange *= 1.5f;
			heightTargetSpeed *= 1.25f;
		}

		if (forwardSpeed <= forwardTargetSpeed) {
			forwardSpeed = MinF(forwardTargetSpeed, forwardSpeed + forwardAccelerateInSec * deltaTime);
			if (forwardSpeed > 0.f) {
				ApplyCrowBehStateIfNew('FlyForward');
			} else {
				ApplyCrowBehStateIfNew('FlyInPlace');
			}
		} else {
			forwardSpeed = MaxF(forwardTargetSpeed, forwardSpeed - forwardAccelerateInSec * deltaTime);
			if (forwardSpeed > 0.f) {
				ApplyCrowBehStateIfNew('GlideForward');
			} else {
				ApplyCrowBehStateIfNew('FlyInPlace');
			}
		}

		if (heightSpeed <= heightTargetSpeed) {
			heightSpeed = MinF(heightTargetSpeed, heightSpeed + heightAccelerateInSec * deltaTime);
		} else {
			heightSpeed = MaxF(heightTargetSpeed, heightSpeed - heightAccelerateInSec * deltaTime);
		}

		if (rollAngle <= rollTargetAngle) {
			rollAngle = MinF(rollTargetAngle, rollAngle + rollChangeInSec * deltaTime);
		} else {
			rollAngle = MaxF(rollTargetAngle, rollAngle - rollChangeInSec * deltaTime);
		}

		if (!inAttackAction) {
			crowRotation.Pitch = LerpAngleF( deltaTime / 0.1f, crowRotation.Pitch, 0.f );
			crowRotation.Roll = rollAngle;
			crowRotation.Yaw += yawAngleChange * deltaTime;
		}
		
		crowPosition += VecFromHeading(crowRotation.Yaw) * forwardSpeed * deltaTime;
		crowPosition.Z += heightSpeed * deltaTime;

		moveVec = VecNormalize(crowPosition - oldCrowPosition);
		sweepTestBumped = world.SweepTest(oldCrowPosition, crowPosition + moveVec, /*radius*/ 0.1f, sweepTracePos, sweepTraceNormal, collisionObstaclesGround);
		if (sweepTestBumped) {
			// NR_Debug("sweepTestBumped 1: moveVec = " + VecToString(moveVec));
			sweepTraceNormal = VecNormalize(sweepTraceNormal);
			moveVec = VecNormalize(LerpV(moveVec, sweepTraceNormal, 0.25f));
			crowPosition = oldCrowPosition + moveVec * forwardSpeed * deltaTime * 0.25f;
			sweepTestBumped = world.SweepTest(oldCrowPosition, crowPosition + moveVec, /*radius*/ 0.1f, sweepTracePos, sweepTraceNormal, collisionObstaclesGround);
			if (sweepTestBumped) {
				// NR_Debug("sweepTestBumped 2: moveVec = " + VecToString(moveVec));
				crowPosition = oldCrowPosition;
			} else {
				// NR_Debug("OK sweepTestBumped 2: moveVec = " + VecToString(moveVec));
			}
		} else {
			// NR_Debug("OK sweepTestBumped 1: moveVec = " + VecToString(moveVec));
		}

		crowPosition.Z = MaxF(crowPosition.Z, world.GetWaterLevel(crowPosition, true) + 0.25f);

		if (oldCrowPosition == crowPosition) {
			crowMovedInTick = false;
		} else {
			crowMovedInTick = true;
		}

		oldCrowPosition = crowPosition;
		transformNPC.TeleportWithRotation( crowPosition, crowRotation );
	}

	public function UpdateInputValues() {
		FB = theInput.GetActionValue( 'GI_AxisLeftY' );
		RL = theInput.GetActionValue( 'GI_AxisLeftX' );
		if ( thePlayer.IsPCModeEnabled() ) {
			inputX = theInput.GetActionValue( 'GI_MouseDampX' );
			inputY = theInput.GetActionValue( 'GI_MouseDampY' );
		} else {
			inputX = theInput.GetActionValue( 'GI_AxisRightX' );
			inputY = theInput.GetActionValue( 'GI_AxisRightY' );
		}
		isAttackPressed = theInput.IsActionPressed( 'AttackWithAlternateLight' );
		isRunPressed = theInput.IsActionPressed( 'Sprint' );
		isJumpPressed = theInput.IsActionPressed( 'Jump' );
		isUsePressed = theInput.IsActionPressed( 'Use' );
		// isPotion4Pressed = theInput.IsActionPressed( 'DrinkPotion4' );
	}

	timer function UpdateStaticCameraTimer( deltaTime : float, id : int ) {
		// NR_Debug("UpdateStaticCameraTimer: old rot = " + NR_EulerToString(cameraRot) + ", target = " + NR_EulerToString(cameraTargetRot));
		UpdateInputValues();

		if (inAttackAction) {
			cameraTargetRot.Yaw = VecHeading(targetPos - crowPosition);
			DampAngleFloatSpring( cameraRot.Yaw, yawVelocity, cameraTargetRot.Yaw, 0.075f, deltaTime );
		} else if (inputX != 0.f) {
			cameraTargetRot.Yaw = cameraTargetRot.Yaw - inputX * 0.2f;
			DampAngleFloatSpring( cameraRot.Yaw, yawVelocity, cameraTargetRot.Yaw, 0.025f, deltaTime );
		}

		if (inputY != 0.f) {
			cameraTargetRot.Pitch = ClampF(cameraTargetRot.Pitch - inputY * 0.1f, -85.f, 85.f);
		}
		DampAngleFloatSpring( cameraRot.Pitch, pitchVelocity, cameraTargetRot.Pitch, 0.025f, deltaTime );

		if (forwardTargetSpeed > 0.f) {
			if (isRunPressed) {
				cameraTargetPos = crowPosition - RotForward(cameraRot) * 1.6f;
			} else {
				cameraTargetPos = crowPosition - RotForward(cameraRot) * 1.55f;
			}
			cameraTargetPos.Z += 0.6f;
		} else {
			cameraTargetPos = crowPosition - RotForward(cameraRot) * 1.5f;
			cameraTargetPos.Z += 0.5f;
		}
		DampVectorSpring( cameraPos, cameraVelocity, cameraTargetPos, 0.05f, deltaTime );
		
		transformedCamera.TeleportWithRotation(cameraPos, cameraRot);
		// NR_Debug("UpdateStaticCameraTimer: new rot = " + NR_EulerToString(cameraRot) + ", target = " + NR_EulerToString(cameraTargetRot));
	}

	event OnLeaveState( nextStateName : name )
	{
		// Pass to base class
		transformedCamera.Stop();
		parent.RemoveTimer('CrowLoopTimer');
		parent.RemoveTimer('UpdateStaticCameraTimer');
		super.OnLeaveState(nextStateName);
	}

	/*
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		// --- super.OnGameCameraTick(moveData, dt);
		parent.playerMoveType = PMT_Idle;
		// NR_Debug("OnGameCameraTick: pivotPositionVelocity = " + VecToString(moveData.pivotPositionVelocity) + ", cameraLocalSpaceOffsetVel = " + VecToString(moveData.cameraLocalSpaceOffsetVel));
		moveData.pivotDistanceController.minDist = 1.f;
		moveData.pivotDistanceController.maxDist = 1.5f;
		moveData.pivotDistanceController.SetDesiredDistance( 1.5f, 1.f );
		moveData.pivotPositionController.SetDesiredPosition( crowPosition, 1.f );
		moveData.pivotPositionController.offsetZ = 0.3f;
		// moveData.pivotRotationController.SetDesiredHeading( crowRotation.Yaw, 0.5f );
		return true;
	}

	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		parent.playerMoveType = PMT_Idle;
		// NR_Debug("OnGameCameraPostTick: pivotPositionVelocity = " + VecToString(moveData.pivotPositionVelocity) + ", cameraLocalSpaceOffsetVel = " + VecToString(moveData.cameraLocalSpaceOffsetVel));
		return true;
	}
	*/
}
