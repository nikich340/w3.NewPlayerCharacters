statemachine class NR_ReplacerWitcher extends W3PlayerWitcher {
	public  var replacerName         : String;
	public  var inventoryTemplate    : String;
	private var deniedInventorySlots : array<name>;
	
	default replacerName      = "nr_replacer_witcher";
	default inventoryTemplate = "nr_replacer_witcher_inv";

	public function SetTeleportedOnBoatToOtherHUB( val : bool )
	{
		NRD("SetTeleportedOnBoatToOtherHUB: " + val);
		super.SetTeleportedOnBoatToOtherHUB( val );
	}


	public function NR_IsSlotDenied(slot : EEquipmentSlots) : bool
	{
		return deniedInventorySlots.Contains( SlotEnumToName(slot) );
	}

	function printInv() {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i, j : int;
		var result : String;
		var equippedOnSlot : EEquipmentSlots;
		var tags : array<name>;

		inv = GetInventory();
		inv.GetAllItems(ids);

		for (i = 0; i < ids.Size(); i += 1) {
			result = "item[" + i + "] ";

			equippedOnSlot = GetItemSlot( ids[i] );

			if(equippedOnSlot != EES_InvalidSlot)
			{
				result += "(slot " + equippedOnSlot + ") ";
			}
			if ( inv.IsItemHeld(ids[i]) )
			{
				result += "(held) ";
			}
			if ( inv.IsItemMounted(ids[i]) )
			{
				result += "(mounted) ";
			}
			if ( inv.GetItemTags(ids[i], tags) )
			{
				result += "{";
				for (j = 0; j < tags.Size(); j += 1) {
					result += tags[j] + ",";
				}
				result += "} ";
				tags.Clear();
			}
			result += inv.GetItemName(ids[i]);
			NR_Notify(result);
		}
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		//var nrPlayerManager : NR_PlayerManager;
		//printInv();		

		NRD(replacerName + " onSpawned!");
		super.OnSpawned( spawnData );

		//nrPlayerManager = NR_GetPlayerManager();
		//nrPlayerManager.AddTimer('NR_FixReplacer', 0.2f, false);
	}

	/*event OnDestroyed()
	{
		NR_Notify("OnDestroyed!");
		super.OnDestroyed();
	}*/
	/*protected function ShouldMount(slot : EEquipmentSlots, item : SItemUniqueId, category : name):bool
	{
		NR_Notify("ShouldMount? slot: " + slot + ", item: " + GetInventory().GetItemName(item));
		return super.ShouldMount(slot, item, category);
	}*/
	/*protected function ShouldMount(slot : EEquipmentSlots, item : SItemUniqueId, category : name):bool
	{
		var NR_mountAllowed : bool = true;
		// prevent mounting clothes which overlaps with replacer template parts
		if (slot == EES_Armor || slot == EES_Boots || slot == EES_Gloves || slot == EES_Pants) {
			NR_mountAllowed = false;
		}

		return NR_mountAllowed && super.ShouldMount(slot, item, category);
	}*/
	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		NR_GetPlayerManager().SetInStoryScene( false );
		super.OnBlockingSceneEnded( output );
	}
	public function UnequipItemFromSlot(slot : EEquipmentSlots, optional reequipped : bool) : bool
	{
		var item : SItemUniqueId;
		var nrPlayerManager : NR_PlayerManager;

		nrPlayerManager = NR_GetPlayerManager();

		/* IsInNonGameplayCutscene() - don't unequip armor for scenes (bath, barber etc) */
		if ( !GetItemEquippedOnSlot(slot, item) )
			return false;

		if ( IsInNonGameplayCutscene() ) {
			nrPlayerManager.SetInStoryScene( true );
			nrPlayerManager.AddTimer('NR_FixReplacer', 0.2f, false);
			NRD("SCENE unequip - call fix");
			return false;
		}

		if ( super.UnequipItemFromSlot(slot, reequipped) ) {
			nrPlayerManager.RemoveSavedItem( item );
			return true;
		} else {
			return false;
		}
	}
	public function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
	{
		var ret : Bool;
		NRD("EquipItemInGivenSlot: slot = " + slot + " ignoreMounting = " + ignoreMounting);
		if (slot == EES_Armor || slot == EES_Boots || slot == EES_Gloves || slot == EES_Pants) {
			ignoreMounting = true;
		}
		ret = super.EquipItemInGivenSlot(item, slot, ignoreMounting, toHand);
		NR_GetPlayerManager().UpdateSavedItem(item);

		return ret;
	}
	public function SetupCombatAction( action : EBufferActionType, stage : EButtonStage )
	{
		if ( !IsInState('NR_TransformIdle') ) {
			super.SetupCombatAction(action, stage);
		}
		NR_Notify("Main: SetupCombatAction: " + action + ", stage: " + stage);
	}
	/*public function EquipItem(item : SItemUniqueId, optional slot : EEquipmentSlots, optional toHand : bool) : bool
	{
		NR_Notify("EquipItem: slot = " + slot);;
		return super.EquipItem(item, slot, toHand);
	}*/

	/*private function NR_stringById(itemId : SItemUniqueId) : String {
		if ( inv.IsIdValid(itemId) )
			return NameToString( inv.GetItemName(itemId) );
		else
			return "<invalid>";
	}
	public function NR_DebugSlots() {
		var item : SItemUniqueId;
		var headManager : CHeadManagerComponent;
		var headName : name;
		var message : String;
	
		headManager = (CHeadManagerComponent)GetComponentByClassName( 'CHeadManagerComponent' );
		message += "<font>HEAD: " + headManager.GetCurHeadName() + "<br />";

		GetItemEquippedOnSlot( EES_SilverSword, item );
		message += "EES_SilverSword: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_SteelSword, item );
		message += "EES_SteelSword: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Armor, item );
		message += "EES_Armor: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Boots, item );
		message += "EES_Boots " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Gloves, item );
		message += "EES_Gloves: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Pants, item );
		message += "EES_Pants: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Hair, item );
		message += "EES_Hair: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Mask, item );
		message += "EES_Mask: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_RangedWeapon, item );
		message += "EES_RangedWeapon: " + NR_stringById(item) + "<br /></font>";
		
		NR_Notify(message, 60.0f);		
	}*/
}

/*
[NR_DEBUG] CExplorationInput: IsJumpPressed? = true
[NR_DEBUG] CExplorationInput: IsJumpPressed? = true
[ExplorationState]  Jump type: EJT_IdleToWalk
[ASSERT] EffectTypeToName: Effect type <<EET_AutoStaminaRegen>> is undefined!
[ASSERT] EffectTypeToName: Effect type <<EET_AutoStaminaRegen>> is undefined!
[Buffs] EffectManager.CheckInteraction: old effect <<W3Effect_AutoStaminaRegen>> overrides new effect <<W3Effect_AutoStaminaRegen>> - DENY
[ExplorationState] 	Substate changing to: JSS_TakingOff
[ExplorationState] State changed by: The state change precheck
[ExplorationSave] Lock, state Jump
[NR_DEBUG] OnGameCameraTick: 0.017296
[HUD_TICK] INPUT CONTEXT CHANGED JumpClimb previousInputContext Exploration
[HUD_TICK] 
[NR_DEBUG] OnGameCameraTick: 0.016006
[ExplorationState] !!!!!!!!!!!!!!ERROR: Jump: FAILED CONFIRMATION: behavior graph node was not entered. this CExplorationState needs a node of type ScriptState in the behavior graph (So it is marked on the state variables),  and it has to have the same name than the CExplorationState and the notification on enter and exit called 'Enter' and 'Exit'.
[ExplorationStateErrors] !!!!!!!!!!!!!!ERROR: Jump: FAILED CONFIRMATION: behavior graph node was not entered. this CExplorationState needs a node of type ScriptState in the behavior graph (So it is marked on the state variables),  and it has to have the same name than the CExplorationState and the notification on enter and exit called 'Enter' and 'Exit'.
[ExplorationState] Jump: StateExit. Took 0.034157 seconds.
[ExplorationState] Jump: Jumped distance: 0.000000 Height: 0.000000
*/
state NR_TransformIdle in NR_ReplacerSorceress extends Base {
	var transformNPC 	: CNewNPC;
	var i, j 			: int;
	var blockedActions 	: array<EInputActionBlock>;

	event OnEnterState( prevStateName : name )
	{
		// Pass to base class
		super.OnEnterState(prevStateName);
		theInput.SetContext( 'Exploration' );

		transformNPC = theGame.GetNPCByTag('NR_TRANSFORM_NPC');
		if (!transformNPC) {
			NRE("Leaving NR_TransformIdle: null transformNPC!");
			GotoState('Exploration');
		}

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

		blockedActions.PushBack( EIAB_Signs );
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

		// ENABLE PUPPET
		for (i = 0; i < blockedActions.Size(); i += 1) {
			parent.BlockAction( blockedActions[i], 'NR_TransformIdle' );
		}
		TooglePlayerPotency(false);

		MainLoop();
	}

	entry function MainLoop() {
		var movementAdjustor	: CMovementAdjustor; 
    	var ticket				: SMovementAdjustmentRequestTicket;
    	var ticketAngle			: float;
    	var ticketAngles		: EulerAngles;
		var isRunning, isJumping, isAttacking, isAttackingAlt	: bool;
		var wasJumping, wasAttacking, wasAttackingAlt	: bool;
		var frameTime, lastJumpTime, lastAttackTime 			: float;
		var Editor_MovementSpeed, lEditor_MovementSpeed : float;
		var Editor_MovementRotation, lEditor_MovementRotation : float;
		var RL, FB, sumAngle, angleToReach, npcHeadingAngle, angleL, angleR : float;
		var numAxises : int;

		var camera : CCustomCamera = theGame.GetGameCamera();		
		if (camera)
		{
			//camera.ChangePivotRotationController('Default');
			camera.ChangePivotPositionController('Default');
			camera.ChangePivotDistanceController('Default');
		}

		lEditor_MovementSpeed 		= 0.f;
		lEditor_MovementRotation 	= 0.f;
		lastJumpTime 				= 0.f;
		lastAttackTime 				= 0.f;
		movementAdjustor = transformNPC.GetMovingAgentComponent().GetMovementAdjustor();

		while (true) {
			SleepOneFrame(); // in case something will do "continue"

			frameTime = theGame.GetEngineTimeAsSeconds();
			// !!! CInputAxisDoubleTap
			isRunning = theInput.IsActionPressed( 'Sprint' );
			isJumping = theInput.IsActionPressed( 'Jump' );
			isAttacking = theInput.IsActionPressed( 'AttackWithAlternateLight' );
			isAttackingAlt = theInput.IsActionPressed( 'AttackWithAlternateHeavy' );

			FB = theInput.GetActionValue( 'GI_AxisLeftY' );
			RL = theInput.GetActionValue( 'GI_AxisLeftX' );

			if (isJumping && !wasJumping && frameTime - lastJumpTime > 1.f && frameTime - lastAttackTime > 2.f) {
				lastJumpTime = frameTime;
				if ( !transformNPC.GetRootAnimatedComponent().RaiseBehaviorEvent( 'RunJump' ) ) {
					NRE("Can't raise event: Jump");
				}
			}
			wasJumping = isJumping;

			if (isAttacking && !wasAttacking && frameTime - lastAttackTime > 2.f && frameTime - lastJumpTime > 1.f) {
				lastAttackTime = frameTime;
				if ( !transformNPC.GetRootAnimatedComponent().RaiseBehaviorEvent( 'Taunt' ) ) {
					NRE("Can't raise event: Taunt");
				}
			}
			wasAttacking = isAttacking;

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

			if (numAxises < 1) { // no any button is pressed
				Editor_MovementSpeed = 0.f;
			} else {
				if (isRunning) { // shift is pressed
					Editor_MovementSpeed = 2.f;
				} else { 		// shift is NOT pressed
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
					ticketAngles.Yaw = -MinF(angleR * 80.f, 80.f); // 60 is empiric coefficient
					movementAdjustor.AddOneFrameRotationVelocity( ticketAngles );
					//NRD("AddOneFrameRotationVelocity Right: " + MinF(angleR * -60.f, -60.f));
				} else {
					ticketAngles.Yaw = MinF(angleL * 80.f, 80.f); // 60 is empiric coefficient
					movementAdjustor.AddOneFrameRotationVelocity( ticketAngles );
					//NRD("AddOneFrameRotationVelocity Left!" + MinF(angleL * -60.f, -60.f));
				}
				/*NRD("AbsF(ticketAngle - angleToReach) = " + AbsF(ticketAngle - angleToReach));
					ticketAngle = angleToReach;
					
					if ( ticket && movementAdjustor.IsRequestActive(ticket) ) {
						movementAdjustor.Cancel( ticket );
					}
					ticket = CreateNewRequest('NR_TRANSFORM_ADJUST_ROTATION');*/
			} else if (angleR < angleL) {
				Editor_MovementRotation = 1.f; // rotate Right
				//NRD("rotate Right!");
			} else {
				Editor_MovementRotation = -1.f; // rotate Left
				//NRD("rotate Left!");
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
		thePlayer.ResetTemporaryAttitudeGroup( AGP_Default );
		// thePlayer.CancelAIBehavior( parent.idleActionId );
		thePlayer.SetManualControl(enable, enable);
	}

	event OnLeaveState( nextStateName : name )
	{	
		// DISABLE PUPET
		TooglePlayerPotency(true);
		for (i = 0; i < blockedActions.Size(); i += 1) {
			parent.UnblockAction( blockedActions[i], 'NR_TransformIdle' );
		}
		((CMovingPhysicalAgentComponent) parent.GetMovingAgentComponent()).SetTerrainInfluence(0.4f);
		
		// Pass to base class
		super.OnLeaveState(nextStateName);

		if( nextStateName == 'PlayerDialogScene') {
			NRD("NR_TransformIdle: TO SCENE!");
		}
		NRD("NR_TransformIdle: " + nextStateName);


		///theInput.RestoreContext('Exploration', true);
	}

	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		virtual_parent.OnBlockingSceneStarted( scene );
		NR_Notify("NR_TransformIdle: OnBlockingSceneStarted: " + scene);
	}

	event OnBlockingSceneStarted_OnIntroCutscene( scene: CStoryScene )
	{
		virtual_parent.OnBlockingSceneStarted_OnIntroCutscene( scene );
		NR_Notify("NR_TransformIdle: OnBlockingSceneStarted_OnIntroCutscene: " + scene);
	}

	public function SetSprintToggle( flag : bool )
	{	
		NRD("NR_TransformIdle: SetSprintToggle: " + flag);
		parent.SetSprintToggle(flag);
	}
	
	public function SetWalkToggle( flag : bool )
	{	
		NRD("NR_TransformIdle: SetWalkToggle: " + flag);
		parent.SetWalkToggle(flag);
	}

	public function SetIsRunning( flag : bool )
	{
		NRD("NR_TransformIdle: SetIsRunning: " + flag);
		parent.isRunning = flag;
	}
	
	function SetIsWalking( walking : bool )
	{
		NRD("NR_TransformIdle: SetIsWalking: " + walking);
		parent.isWalking	= walking;
	}

	public function SetupCombatAction( action : EBufferActionType, stage : EButtonStage )
	{
		NRD("NR_TransformIdle: SetupCombatAction: " + action + ", stage: " + stage);
		virtual_parent.SetupCombatAction(action, stage);
	}

	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		//super.OnGameCameraTick(moveData, dt);

		// closer to cat
		moveData.pivotDistanceController.SetDesiredDistance( 1.f );
		moveData.pivotPositionController.SetDesiredPosition( transformNPC.GetWorldPosition() );
		moveData.pivotPositionController.offsetZ = 0.5f;
		NRD("OnGameCameraTick: " + dt);
		return true;
	}
}

function NR_GetWitcherReplacer() : NR_ReplacerWitcher
{
	return (NR_ReplacerWitcher)thePlayer;
}