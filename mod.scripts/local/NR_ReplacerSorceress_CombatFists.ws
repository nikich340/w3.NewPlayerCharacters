/* State is overwritten for 2 purposes: to add custom combo aspects, and to handle anim events */

state CombatFists in NR_ReplacerSorceress extends Combat
{
	event OnEnterState( prevStateName : name )
	{
		theInput.SetContext(parent.GetCombatInputContext());
		parent.AddAnimEventCallback('InitAction',			'OnAnimEventMagic');
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

	event OnLeaveState( nextStateName : name ) {
		parent.RemoveAnimEventCallback('InitAction');
		parent.RemoveAnimEventCallback('Prepare');
		parent.RemoveAnimEventCallback('Spawn');
		parent.RemoveAnimEventCallback('Shoot');
		parent.RemoveAnimEventCallback('PerformMagicAttack');
		parent.RemoveAnimEventCallback('PrepareTeleport');
		parent.RemoveAnimEventCallback('PerformTeleport');

		startupAction = IA_None;
		this.CombatFistsDone( nextStateName );
		super.OnLeaveState(nextStateName);		
	}

	event OnPerformEvade( playerEvadeType : EPlayerEvadeType )
	{
		NRD("combatFists:: OnPerformEvade");
		PerformTeleport( playerEvadeType, playerEvadeType == PET_Roll);
		return true;
	}

	entry function PerformTeleport( playerEvadeType : EPlayerEvadeType, isRolling : bool )
	{
		var evadeTarget 			: CActor;
		var teleportLength : float;
		var playerToTargetHeading : float;

		var foundSafePoint 		: bool;
		var attempsToFindPoint	: int;
		var currentPos 			: Vector;
		var predictedDodgePos 	: Vector;
		var predictedDodgeRot 	: EulerAngles;
		var Z : float;

		if ( !parent.magicManager.HasStaminaForAction( ENR_Teleport ) )
			return;

		teleportLength = parent.magicManager.GetTeleportDistance(playerEvadeType == PET_Roll);

		parent.ResetUninterruptedHitsCount();		
		parent.SetIsCurrentlyDodging(true, true);

		if ( parent.IsHardLockEnabled() && parent.GetTarget() )
			evadeTarget = parent.GetTarget();
		else
		{
			parent.FindMoveTarget();
			evadeTarget = parent.moveTarget;		
		}

		currentPos = parent.GetWorldPosition();
		predictedDodgeRot = parent.GetWorldRotation();
		predictedDodgePos = VecFromHeading( parent.rawPlayerHeading ) * teleportLength + currentPos;
		NR_GetSafeTeleportPoint( predictedDodgePos ); // snap to ground
		predictedDodgePos = NR_GetTeleportMaxArchievablePoint( thePlayer, currentPos, predictedDodgePos );

		foundSafePoint = NR_GetSafeTeleportPoint( predictedDodgePos );
		attempsToFindPoint = 5;
		// binary decrease teleportLength
		while (!foundSafePoint) {
			if (!attempsToFindPoint) {
				predictedDodgePos = currentPos;
				break;
			}
			NRD("foundSafePoint: left " + attempsToFindPoint);
			attempsToFindPoint -= 1;
			playerEvadeType = PET_Dodge; // since we decreased length to 6.0 or less

			teleportLength = teleportLength / 2.f;
			predictedDodgePos = VecFromHeading( parent.rawPlayerHeading ) * teleportLength + currentPos;
			foundSafePoint = NR_GetSafeTeleportPoint( predictedDodgePos );
		}
		NRD("Found safe tp pos with length: " + teleportLength + ", pos: " + VecToString(predictedDodgePos) + ", playerPos: " + VecToString(parent.GetWorldPosition()));

		if (evadeTarget) {
			playerToTargetHeading = VecHeading( evadeTarget.GetWorldPosition() - predictedDodgePos );
			// rotate face to enemy face if angle diff < 90
			if ( AbsF(AngleDistance(theCamera.GetCameraHeading(), playerToTargetHeading)) < 90 ) {
				// rotate to target
				predictedDodgeRot.Yaw = playerToTargetHeading;
			}
		}
		parent.magicManager.SetActionType( ENR_Teleport );
		parent.magicManager.aTeleportPos = predictedDodgePos;

		NRD("TELEPORT: rawPlayerHeading = " + parent.rawPlayerHeading + ", playerToTargetHeading = " + playerToTargetHeading);
		parent.SetBehaviorVariable( 'dodgeNum', 0 );
		parent.SetBehaviorVariable( 'combatActionType', (int)CAT_Dodge );
		parent.SetBehaviorVariable(	'playerEvadeDirection', (int)PED_Forward );
		parent.SetBehaviorVariable(	'turnInPlaceBeforeDodge', 0.f );
		parent.SetBehaviorVariable(	'isRolling', 0 );
		parent.SetBehaviorVariable(	'NR_isMagicAttack', 1 );

		if ( parent.RaiseForceEvent( 'CombatAction' ) )
		{
			// protect from interrupting teleport (DisallowHitAnim doesn't always help)
			//parent.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			//parent.SetImmortalityMode( AIM_Invulnerable, AIC_Default );

			// Perk 21 - all defensive actions generate adrenaline
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
		// it is set in magicManager on teleport end
		//parent.SetImmortalityMode( AIM_None, AIC_Combat );
		//parent.SetImmortalityMode( AIM_None, AIC_Default );
	}

	event OnInterruptAttack() {
		NRD("OnInterruptAttack!");
		return virtual_parent.OnInterruptAttack();
	}

	latent function NR_EquipMagicFists() {
		var ids : array<SItemUniqueId>;
		thePlayer.inv.RemoveItemByCategory('fist', -1);

		ids = thePlayer.inv.AddAnItem('nr_fists', 1, true, true, false);
		parent.magicManager.UpdateFistsLevel( ids[0] );

		parent.SetRequiredItems('Any', 'fist' );
		parent.ProcessRequiredItems();
		parent.magicManager.HandFX(true);
	}
	latent function NR_UnequipMagicFists() {
		parent.magicManager.HandFX(false);
		thePlayer.inv.RemoveItemByCategory('fist', -1);
		thePlayer.inv.AddAnItem( 'Geralt fists', 1, true, true, false );

		// needed?
		//parent.SetRequiredItems('Any', 'fist' );
		//parent.ProcessRequiredItems();
	}
	
	
	var action : SInputAction;
	
	entry function CombatFistsInit( prevStateName : name )
	{
		parent.SetBIsCombatActionAllowed( true );
		BuildComboPlayer();
		parent.LockEntryFunction( false );
		NRD("CombatFistsInit: " + startupAction);
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
		CreateAttackNoStaminaAspect();

		CreateAttackLightAspect();
		CreateAttackHeavyAspect();
		CreateAttackSpecialAspect();
		CreateAttackSpecialLongAspect();
		CreateAttackFinisherAspect();
		CreateAttackPushAspect();
	}

	private final function CreateAttackNoStaminaAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackNoStamina' );
		
		{
			str = aspect.CreateComboString( false );

			str.AddDirAttack( 'woman_sorceress_effect_immobile_nulify', AD_Front, ADIST_Medium );
			str.AddAttack( 'woman_sorceress_effect_immobile_nulify', ADIST_Medium );
		}	
		{
			str = aspect.CreateComboString( true );

			str.AddDirAttack( 'woman_sorceress_effect_immobile_nulify', AD_Front, ADIST_Medium );
			str.AddAttack( 'woman_sorceress_effect_immobile_nulify', ADIST_Medium );
		}

		aspect = comboDefinition.CreateComboAspect( 'AttackIdle' );
		
		{
			str = aspect.CreateComboString( false );

			str.AddDirAttack( 'woman_sorceress_effect_immobile_nulify', AD_Front, ADIST_Medium );
			str.AddAttack( 'woman_sorceress_effect_immobile_nulify', ADIST_Medium );
		}	
		{
			str = aspect.CreateComboString( true );

			str.AddDirAttack( 'woman_sorceress_effect_immobile_nulify', AD_Front, ADIST_Medium );
			str.AddAttack( 'woman_sorceress_effect_immobile_nulify', ADIST_Medium );
		}
	}
	
	private final function CreateAttackLightAspect()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;

		/* 2.3 (1.1) */
		aspect = comboDefinition.CreateComboAspect( 'AttackLightSlash' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_attack_slash_right_rp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_slash_left_rp', AD_Front, ADIST_Medium );

			str.AddAttack( 'woman_sorceress_attack_slash_right_rp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_slash_left_rp', ADIST_Medium );

			aspect.AddLink('woman_sorceress_attack_slash_right_rp', 'woman_sorceress_attack_slash_left_rp');
			aspect.AddLink('woman_sorceress_attack_slash_left_rp', 'woman_sorceress_attack_slash_right_rp');
		}
		{
			str = aspect.CreateComboString( true );
			str.AddDirAttack( 'woman_sorceress_attack_slash_right_lp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_slash_left_lp', AD_Front, ADIST_Medium );

			str.AddAttack( 'woman_sorceress_attack_slash_right_lp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_slash_left_lp', ADIST_Medium );

			aspect.AddLink('woman_sorceress_attack_slash_right_lp', 'woman_sorceress_attack_slash_left_lp');
			aspect.AddLink('woman_sorceress_attack_slash_left_lp', 'woman_sorceress_attack_slash_right_lp');
		}

		/* 2.0 (1.2) */
		aspect = comboDefinition.CreateComboAspect( 'AttackLightThrow' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_attack_throw_rp_01', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_attack_throw_rp_01', ADIST_Medium );
		}
		{
			str = aspect.CreateComboString( true );
			str.AddDirAttack( 'woman_sorceress_attack_throw_lp_04', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_attack_throw_lp_04', ADIST_Medium );
		}
	}
	
	private final function CreateAttackHeavyAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		/* 3.0 (1.9) */
		aspect = comboDefinition.CreateComboAspect( 'AttackHeavyRock' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_attack_rock_rhand_rp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_rock_lhand_rp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_rock_bhand_rp', AD_Front, ADIST_Medium );

			str.AddAttack( 'woman_sorceress_attack_rock_rhand_rp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_rock_lhand_rp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_rock_bhand_rp', ADIST_Medium );

			aspect.AddLink('woman_sorceress_attack_rock_rhand_rp', 'woman_sorceress_attack_rock_lhand_rp');
			aspect.AddLink('woman_sorceress_attack_rock_lhand_rp', 'woman_sorceress_attack_rock_bhand_rp');
			aspect.AddLink('woman_sorceress_attack_rock_bhand_rp', 'woman_sorceress_attack_rock_rhand_rp');
		}
		{
			str = aspect.CreateComboString( true );
			str.AddDirAttack( 'woman_sorceress_attack_rock_rhand_lp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_rock_lhand_lp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_rock_bhand_lp', AD_Front, ADIST_Medium );	

			str.AddAttack( 'woman_sorceress_attack_rock_rhand_lp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_rock_lhand_lp', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_rock_bhand_lp', ADIST_Medium );

			aspect.AddLink('woman_sorceress_attack_rock_rhand_lp', 'woman_sorceress_attack_rock_lhand_lp');
			aspect.AddLink('woman_sorceress_attack_rock_lhand_lp', 'woman_sorceress_attack_rock_bhand_lp');
			aspect.AddLink('woman_sorceress_attack_rock_bhand_lp', 'woman_sorceress_attack_rock_rhand_lp');
		}

		/* 2.0 (1.2) */
		aspect = comboDefinition.CreateComboAspect( 'AttackHeavyThrow' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_attack_throw_rp_03', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_throw_rp_01', AD_Front, ADIST_Medium );

			str.AddAttack( 'woman_sorceress_attack_throw_rp_03', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_throw_rp_01', ADIST_Medium );

			aspect.AddLink('woman_sorceress_attack_throw_rp_03', 'woman_sorceress_attack_throw_rp_01');
			aspect.AddLink('woman_sorceress_attack_throw_rp_01', 'woman_sorceress_attack_throw_rp_03');
		}
		{
			str = aspect.CreateComboString( true );
			str.AddDirAttack( 'woman_sorceress_attack_throw_lp_03', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'woman_sorceress_attack_throw_lp_04', AD_Front, ADIST_Medium );

			str.AddAttack( 'woman_sorceress_attack_throw_lp_03', ADIST_Medium );
			str.AddAttack( 'woman_sorceress_attack_throw_lp_04', ADIST_Medium );

			aspect.AddLink('woman_sorceress_attack_throw_lp_03', 'woman_sorceress_attack_throw_lp_04');
			aspect.AddLink('woman_sorceress_attack_throw_lp_04', 'woman_sorceress_attack_throw_lp_03');
		}
	}

	private final function CreateAttackFinisherAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		/* 4.5 (3.0) */
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
		
		/* 0.7 (0.2) */
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

		/* AARD, YRDEN == HeavyThrow */
		/* QUEN handled by w2beh (have separate anims with special events == edited taunts)
			woman_sorceress_special_quen_lp == taunt_02_lp, 
			woman_sorceress_special_quen_rp == taunt_02_rp 
		*/
		// taunt_01_rp == "heal"
		// taunt_02_rp == "shield"
		// taunt_03_rp == ?"transform"
		// electricity_lp == "cast" / ?"transform"

		/* hack to use woman_sorceress_special_attack_electricity_lp for rp */
		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialFastTravelTeleport' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_special_attack_fireball_lp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_special_attack_fireball_lp', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'woman_sorceress_special_attack_fireball_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_special_attack_fireball_lp', ADIST_Medium );
		}

		/* 3.33 (1.7) */
		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialElectricity' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_special_attack_electricity_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_special_attack_electricity_rp', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'woman_sorceress_special_attack_electricity_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_special_attack_electricity_lp', ADIST_Medium );
		}

		/* 2.8 (1.66) */
		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialPray' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_pray_cast_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_pray_cast_rp', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'woman_sorceress_pray_cast_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_pray_cast_lp', ADIST_Medium );
		}

		/* 3.33 (1.1974) */
		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialFireball' );
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

		/* 3.333 (1.1) */
		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialShield' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_special_quen_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_special_quen_rp', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'woman_sorceress_special_quen_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_special_quen_lp', ADIST_Medium );
		}

		/* 3.0 (2.0) */
		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialHeal' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_heal_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_heal_rp', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'woman_sorceress_heal_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_heal_lp', ADIST_Medium );
		}

		/* 4.166 (3.0) */
		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialTransform' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'woman_sorceress_special_attack_electricity_rp', AD_Front, ADIST_Medium );		
			str.AddAttack( 'woman_sorceress_special_attack_electricity_rp', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'woman_sorceress_special_attack_electricity_lp', AD_Front, ADIST_Medium );	
			str.AddAttack( 'woman_sorceress_special_attack_electricity_lp', ADIST_Medium );
		}
	}

	private final function CreateAttackSpecialLongAspect()
	{
		var aspect : CComboAspect;
		var str : CComboString;

		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialLongYenChanting' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'nr_q403_yennefer_chanting_spell', AD_Front, ADIST_Medium );		
			str.AddAttack( 'nr_q403_yennefer_chanting_spell', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'q403_yennefer_chanting_spell', AD_Front, ADIST_Medium );	
			str.AddAttack( 'q403_yennefer_chanting_spell', ADIST_Medium );
		}

		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialLongCiriTargeting' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'nr_ciri_targeting_for_triss_meteorite_rp_loop', AD_Front, ADIST_Medium );		
			str.AddAttack( 'nr_ciri_targeting_for_triss_meteorite_rp_loop', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'nr_ciri_targeting_for_triss_meteorite_lp_loop', AD_Front, ADIST_Medium );	
			str.AddAttack( 'nr_ciri_targeting_for_triss_meteorite_lp_loop', ADIST_Medium );
		}

		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialLongYenNaglfar' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'nr_yennefer_naglfar_arrives_loop_01', AD_Front, ADIST_Medium );		
			str.AddAttack( 'nr_yennefer_naglfar_arrives_loop_01', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'nr_yennefer_naglfar_arrives_loop_01', AD_Front, ADIST_Medium );	
			str.AddAttack( 'nr_yennefer_naglfar_arrives_loop_01', ADIST_Medium );
		}

		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialLongMargeritaNaglfar' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'nr_margerita_naglfar_arrives_loop_01', AD_Front, ADIST_Medium );		
			str.AddAttack( 'nr_margerita_naglfar_arrives_loop_01', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'nr_margerita_naglfar_arrives_loop_01', AD_Front, ADIST_Medium );	
			str.AddAttack( 'nr_margerita_naglfar_arrives_loop_01', ADIST_Medium );
		}

		aspect = comboDefinition.CreateComboAspect( 'AttackSpecialLongSorceress' );
		{
			str = aspect.CreateComboString( false );
			str.AddDirAttack( 'nr_sorceress_casting_short_spell_loop', AD_Front, ADIST_Medium );		
			str.AddAttack( 'nr_sorceress_casting_short_spell_loop', ADIST_Medium );
		}			
		{
			str = aspect.CreateComboString( true );		
			str.AddDirAttack( 'nr_sorceress_casting_short_spell_loop', AD_Front, ADIST_Medium );	
			str.AddAttack( 'nr_sorceress_casting_short_spell_loop', ADIST_Medium );
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
