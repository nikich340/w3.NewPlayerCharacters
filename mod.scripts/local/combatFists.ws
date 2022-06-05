/*enum EInitialAction
{
	IA_None,
	IA_AttackLight,
	IA_AttackHeavy,
	IA_CastSign,
	IA_ThrowItem,
	IA_CriticalState,
}*/


state CombatFists in NR_ReplacerSorceress extends Combat
{
	event OnEnterState( prevStateName : name )
	{
		theInput.SetContext(parent.GetCombatInputContext());
		parent.AddAnimEventCallback('Prepare',				'OnAnimEventMagic');
		parent.AddAnimEventCallback('Spawn',				'OnAnimEventMagic');
		parent.AddAnimEventCallback('Shoot',				'OnAnimEventMagic');
		parent.AddAnimEventCallback('PerformMagicAttack',	'OnAnimEventMagic');
		//parent.AddAnimEventCallback('AllowBlend',	'OnAnimEventBlend');
		parent.AddAnimEventCallback('PrepareTeleport',		'OnAnimEventMagic');
		parent.AddAnimEventCallback('PerformTeleport',		'OnAnimEventMagic');

		super.OnEnterState(prevStateName);
		this.CombatFistsInit( prevStateName );		
	}
	event OnAnimEventMagic( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var magicEvent : SNR_MagicEvent;

		if (animEventType != AET_Tick) {
			NR_Notify("ERROR! Wrong animEventType: " + animEventType);
			return false;
		}
		magicEvent.eventName = animEventName;
		magicEvent.animName = GetAnimNameFromEventAnimInfo(animInfo);
		magicEvent.animTime = GetLocalAnimTimeFromEventAnimInfo(animInfo);
		//magicEvent.eventDuration = GetEventDurationFromEventAnimInfo(animInfo);
		NR_Notify("OnAnimEventMagic:: eventName = " + magicEvent.eventName + ", type = " + animEventType + ", animName = " + magicEvent.animName);
		// will be auto-processed async in next frame
		parent.magicMan.aEventsStack.PushBack(magicEvent);
	}
	
	event OnPreAttackEvent(animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo)
	{
		if (animEventType == AET_DurationStart) {
			// must be processed in sync to change data var
			parent.magicMan.OnPreAttackEvent(GetAnimNameFromEventAnimInfo(animInfo), data);
		}
		virtual_parent.OnPreAttackEvent(animEventName, animEventType, data, animInfo);
	}

	event OnPerformEvade( playerEvadeType : EPlayerEvadeType )
	{
		NR_Notify("combatFists:: OnPerformEvade");
		PerformTeleport( playerEvadeType, playerEvadeType == PET_Roll);
		return true;
	}

	entry function PerformTeleport( playerEvadeType : EPlayerEvadeType, isRolling : bool )
	{
		var evadeTarget 			: CActor;
		var teleportLength : float;
		var playerToTargetHeading : float;

		var foundSafePoint 		: bool;
		var predictedDodgePos : Vector;
		var predictedDodgeRot : EulerAngles;
		var Z : float;

		if (playerEvadeType == PET_Roll && parent.HasStaminaToUseAction( ESAT_HeavyAttack,,1.f )) {
			teleportLength = 15.0f;
		} else if (parent.HasStaminaToUseAction( ESAT_LightSpecial,,1.f )) {
			teleportLength = 7.5f;
		} else {
			return;
		}

		parent.ResetUninterruptedHitsCount();		
		parent.SetIsCurrentlyDodging(true, true);

		if ( parent.IsHardLockEnabled() && parent.GetTarget() )
			evadeTarget = parent.GetTarget();
		else
		{
			parent.FindMoveTarget();
			evadeTarget = parent.moveTarget;		
		}

		predictedDodgePos = VecFromHeading( parent.rawPlayerHeading ) * teleportLength + parent.GetWorldPosition();
		predictedDodgeRot = parent.GetWorldRotation();

		predictedDodgePos = VecFromHeading( parent.rawPlayerHeading ) * teleportLength + parent.GetWorldPosition();
		predictedDodgeRot = parent.GetWorldRotation();
		foundSafePoint = GetSafeTeleportPoint( predictedDodgePos );

		// binary decrease teleportLength
		while (!foundSafePoint) {
			playerEvadeType = PET_Dodge; // since we decreased length to 6.0 or less

			teleportLength = teleportLength / 2.f;
			predictedDodgePos = VecFromHeading( parent.rawPlayerHeading ) * teleportLength + parent.GetWorldPosition();
			foundSafePoint = GetSafeTeleportPoint( predictedDodgePos );
		}
		NR_Notify("Found safe tp pos with length: " + teleportLength + ", pos: " + VecToString(predictedDodgePos) + ", playerPos: " + VecToString(parent.GetWorldPosition()));

		if (evadeTarget) {
			playerToTargetHeading = VecHeading( evadeTarget.GetWorldPosition() - predictedDodgePos );
			// rotate face to enemy face if angle diff < 90
			if ( AbsF(AngleDistance(theCamera.GetCameraHeading(), playerToTargetHeading)) < 90 ) {
				// rotate to target
				predictedDodgeRot.Yaw = playerToTargetHeading;
			}
		}
		parent.magicMan.aTeleportPos = predictedDodgePos;

		NR_Notify("TELEPORT: rawPlayerHeading = " + parent.rawPlayerHeading + ", playerToTargetHeading = " + playerToTargetHeading);
		parent.SetBehaviorVariable( 'dodgeNum', 0 );
		parent.SetBehaviorVariable( 'combatActionType', (int)CAT_Dodge );
		parent.SetBehaviorVariable(	'playerEvadeDirection', (int)PED_Forward ) ;
		parent.SetBehaviorVariable(	'turnInPlaceBeforeDodge', 0.f ) ;
		parent.SetBehaviorVariable(	'isRolling', 0 ) ;
		parent.SetBehaviorVariable(	'NR_isMagicAttack', 1 ) ;

		if ( parent.RaiseForceEvent( 'CombatAction' ) )
		{
			// protect from interrupting teleport (DisallowHitAnim doesn't always help)
			parent.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			parent.SetImmortalityMode( AIM_Invulnerable, AIC_Default );

			// TODO
			if( playerEvadeType == PET_Dodge ) {
				parent.DrainStamina(ESAT_HeavyAttack,,,,,1.f);
			} else {
				parent.DrainStamina(ESAT_LightSpecial,,,,,1.f);
			}
			if( parent.CanUseSkill(S_Perk_21) )
			{
				if( playerEvadeType == PET_Dodge ) {
					GetWitcherPlayer().GainAdrenalineFromPerk21( 'dodge' );
				} else {
					GetWitcherPlayer().GainAdrenalineFromPerk21( 'roll' );
				}
			}
			virtual_parent.OnCombatActionStart();
		}

		parent.WaitForBehaviorNodeDeactivation( 'DodgeComplete', 1.5f );
		parent.SetIsCurrentlyDodging(false);
		// it is set in magicMan on teleport end
		//parent.SetImmortalityMode( AIM_None, AIC_Combat );
		//parent.SetImmortalityMode( AIM_None, AIC_Default );
	}
	latent function GetSafeTeleportPoint(out tpPos : Vector) : bool {
		var newPos : Vector;
		var newZ : float;

		// from IsPointSuitableForTeleport()
		if ( !theGame.GetWorld().NavigationFindSafeSpot( tpPos, 0.5f, 0.5f*3, newPos ) )
		{
			if ( theGame.GetWorld().NavigationComputeZ(tpPos, tpPos.Z - 7.f, tpPos.Z + 7.f, newZ) )
			{
				tpPos.Z = newZ;
				if ( !theGame.GetWorld().NavigationFindSafeSpot( tpPos, 0.5f, 0.5f*3, newPos ) )
					return false;
			}
			else
			{
				return false;
			}
		}
		if ( theGame.GetWorld().PhysicsCorrectZ(newPos, newZ) ) {
			newPos.Z = newZ;
		}

		tpPos = newPos;
		return true;
	}

	event OnInterruptAttack() {
		NR_Notify("OnInterruptAttack!");
		return virtual_parent.OnInterruptAttack();
	}

	latent function NR_EquipMagicFists() {
		var ids : array<SItemUniqueId>;
		thePlayer.inv.RemoveItemByCategory('fist', -1);

		ids = thePlayer.inv.AddAnItem('nr_fists', 1, true, true, false);
		parent.magicMan.UpdateFistsLevel( ids[0] );

		parent.SetRequiredItems('Any', 'fist' );
		parent.ProcessRequiredItems();
		parent.magicMan.HandFX(true);
	}
	latent function NR_UnequipMagicFists() {
		parent.magicMan.HandFX(false);
		thePlayer.inv.RemoveItemByCategory('fist', -1);
		thePlayer.inv.AddAnItem( 'Geralt fists', 1, true, true, false );

		// needed?
		//parent.SetRequiredItems('Any', 'fist' );
		//parent.ProcessRequiredItems();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		startupAction = IA_None;

		this.CombatFistsDone( nextStateName );
		
		super.OnLeaveState(nextStateName);		
	}
	
	
	var action : SInputAction;
	
	entry function CombatFistsInit( prevStateName : name )
	{
		parent.SetBIsCombatActionAllowed( true );
		BuildComboPlayer();
		parent.LockEntryFunction( false );
		NR_Notify("CombatFistsInit: " + startupAction);
		switch( startupAction )
		{
			case IA_AttackLight:
				parent.SetPrevRawLeftJoyRot();
				parent.SetupCombatAction( EBAT_LightAttack, BS_Pressed );
				break;
			
			case IA_AttackHeavy:
				parent.SetPrevRawLeftJoyRot();
				parent.SetupCombatAction( EBAT_HeavyAttack, BS_Pressed );
				break;
			
			case IA_CastSign:
				parent.SetupCombatAction( EBAT_CastSign, BS_Pressed );
				break;
			
			case IA_ThrowItem:
				if ( parent.CanSetupCombatAction_Throw() )
				{
					parent.SetupCombatAction( EBAT_ItemUse, BS_Pressed );					
				}
				break;
			case IA_CriticalState:
				parent.CriticalBuffInformBehavior( startupBuff );
				break;
			
			default:
				Log( "Enter CombatFists w/out attacking" );
		}		
		
		NR_EquipMagicFists();
		CombatFistsLoop();	
	}
	
	entry function CombatFistsDone( nextStateName : name )
	{
		NR_UnequipMagicFists();
	}
	
	
	latent function CombatFistsLoop()
	{
		while( true )
		{
			Sleep( 0.5 );
		}		
	}

	
	event OnCombatActionStart()
	{
		parent.SetCombatIdleStance( 1.f );
		parent.OnCombatActionStart();
	}
	
	event OnCombatActionEnd()
	{
		parent.OnCombatActionEnd();	
	}

	event OnCombatActionEndComplete()
	{
		super.OnCombatActionEndComplete();	
	}
	
	event OnCreateAttackAspects()
	{
		CreateAttackLightAspect();
		CreateAttackHeavyAspect();
		CreateAttackSpecialAspect();
		CreateAttackFinisherAspect();
		CreateAttackPushAspect();
	}

	private final function CreateAttackLightAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackLight' );
		
		{
			str = aspect.CreateComboString( false );
			//str.AddDirAttack( 'woman_sorceress_attack_slash_right_rp', AD_Front, ADIST_Small );
			//str.AddDirAttack( 'woman_sorceress_attack_slash_left_rp', AD_Front, ADIST_Small );

			str.AddDirAttack( 'woman_sorceress_attack_slash_right_rp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_slash_left_rp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_throw_rp_01', AD_Front, ADIST_Medium );	
			//str.AddDirAttack( 'man_fistfight_attack_fast_back_1_lh_40ms', AD_Back, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Medium );

			//str.AddAttack( 'woman_sorceress_attack_slash_right_rp', ADIST_Small );
			//str.AddAttack( 'woman_sorceress_attack_slash_left_rp', ADIST_Small );

			str.AddAttack( 'woman_sorceress_attack_slash_right_rp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_slash_left_rp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_throw_rp_01', ADIST_Medium );

			aspect.AddLink('woman_sorceress_attack_slash_right_rp', 'woman_sorceress_attack_slash_left_rp');
			aspect.AddLink('woman_sorceress_attack_slash_left_rp', 'woman_sorceress_attack_throw_rp_01');
			aspect.AddLink('woman_sorceress_attack_throw_rp_01', 'woman_sorceress_attack_slash_right_rp');
		}	
		{
			str = aspect.CreateComboString( true );
			//str.AddDirAttack( 'woman_sorceress_attack_slash_right_lp', AD_Front, ADIST_Small );
			//str.AddDirAttack( 'woman_sorceress_attack_slash_left_lp', AD_Front, ADIST_Small );

			str.AddDirAttack( 'woman_sorceress_attack_slash_right_lp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_slash_left_lp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_throw_lp_03', AD_Front, ADIST_Medium );	
			//str.AddDirAttack( 'man_fistfight_attack_fast_back_1_lh_40ms', AD_Back, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Medium );

			//str.AddAttack( 'woman_sorceress_attack_slash_right_rp', ADIST_Small );
			//str.AddAttack( 'woman_sorceress_attack_slash_left_rp', ADIST_Small );

			str.AddAttack( 'woman_sorceress_attack_slash_right_lp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_slash_left_lp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_throw_lp_03', ADIST_Medium );

			aspect.AddLink('woman_sorceress_attack_slash_right_lp', 'woman_sorceress_attack_slash_left_lp');
			aspect.AddLink('woman_sorceress_attack_slash_left_lp', 'woman_sorceress_attack_throw_lp_03');
			aspect.AddLink('woman_sorceress_attack_throw_lp_03', 'woman_sorceress_attack_slash_right_lp');
		}
	}
	
	private final function CreateAttackHeavyAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackHeavy' );
		
		{
			str = aspect.CreateComboString( false );
						
			str.AddDirAttack( 'woman_sorceress_attack_rock_rhand_rp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_arcane_rp_03', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_rock_lhand_rp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_arcane_rp_01', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_rock_bhand_rp', AD_Front, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Medium );			

			str.AddAttack( 'woman_sorceress_attack_rock_rhand_rp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_arcane_rp_03', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_rock_lhand_rp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_arcane_rp_01', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_rock_bhand_rp', ADIST_Medium );
		}		
		
		
		{
			str = aspect.CreateComboString( true );
						
			str.AddDirAttack( 'woman_sorceress_attack_rock_rhand_lp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_arcane_lp_03', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_rock_lhand_lp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_arcane_lp_04', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_rock_bhand_lp', AD_Front, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Medium );
			//str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Medium );			

			str.AddAttack( 'woman_sorceress_attack_rock_rhand_lp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_arcane_lp_03', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_rock_lhand_lp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_arcane_lp_04', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_rock_bhand_rp', ADIST_Medium );
		}	
	}

	private final function CreateAttackFinisherAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackFinisher' );
		
		{
			str = aspect.CreateComboString( false );	
			str.AddDirAttack( 'woman_sorceress_rip_apart_kill_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_rip_apart_kill_rp', ADIST_Medium );
		}		

		{
			str = aspect.CreateComboString( true );	
			str.AddDirAttack( 'woman_sorceress_rip_apart_kill_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_rip_apart_kill_lp', ADIST_Medium );
		}
	}

	private final function CreateAttackPushAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackPush' );
		
		{
			str = aspect.CreateComboString( false );	
			str.AddDirAttack( 'woman_sorceress_attack_push_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_attack_push_rp', ADIST_Medium );
		}		
		
		{
			str = aspect.CreateComboString( true );	
			str.AddDirAttack( 'woman_sorceress_attack_push_lp_02', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_attack_push_lp_02', ADIST_Medium );
		}
	}

	private final function CreateAttackSpecialAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialIgni' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_special_attack_fireball_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_special_attack_fireball_rp', ADIST_Medium );
		}		
		
		
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'woman_sorceress_special_attack_fireball_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_special_attack_fireball_lp', ADIST_Medium );
		}

		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialQuen' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_taunt_02_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_taunt_02_rp', ADIST_Medium );
		}		
		
		
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'woman_sorceress_taunt_02_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_taunt_02_lp', ADIST_Medium );
		}
	}

	event OnGuardedReleased()
	{
	}
	
	event OnUnconsciousEnd()
	{
		parent.OnUnconsciousEnd();
	}
}
