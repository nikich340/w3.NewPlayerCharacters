statemachine class NR_ReplacerWitcheress extends NR_ReplacerWitcher {
	default replacerName      = "nr_replacer_witcheress";
	default inventoryTemplate = "nr_replacer_witcheress_inv";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );

		AddAnimEventCallback( 'SlideToTarget', 	'OnAnimEvent_SlideToTarget' );
		AddAnimEventCallback( 'item', 	'OnAnimEvent_item' );

		//BlockAction( EIAB_Signs, 'being_NR_ReplacerWoman' );
		//BlockAction( EIAB_OpenInventory, 'being_NR_ReplacerWoman' );
		//BlockAction( EIAB_OpenGwint, 'being_ciri' );
		//BlockAction( EIAB_FastTravel, 'being_NR_ReplacerWoman' );
	//BlockAction( EIAB_Fists, 'being_NR_ReplacerWoman' );
		//BlockAction( EIAB_OpenMeditation, 'being_NR_ReplacerWoman' );
		//BlockAction( EIAB_OpenCharacterPanel, 'being_NR_ReplacerWoman' );
		//BlockAction( EIAB_OpenJournal, 'being_ciri' );
		
		////BlockAction( EIAB_OpenAlchemy, 'being_NR_ReplacerWoman' );	
		
		//BlockAction( EIAB_OpenGlossary, 'being_NR_ReplacerWoman' );	
		//BlockAction( EIAB_CallHorse, 'being_ciri' );
	//BlockAction( EIAB_ExplorationFocus, 'being_NR_ReplacerWoman' );
		
		////BlockAction( EIAB_HeavyAttacks, 'being_NR_ReplacerWoman' );
		
		// Needed?
		//SetBehaviorVariable( 'test_ciri_replacer', 1.0f);
		//theGame.GameplayFactsRemove( "PlayerIsGeralt" );
	}
	protected function Attack( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity)
    {
        var action : W3Action_Attack;
        
        if(PrepareAttackAction(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity, action))
        {
            theGame.damageMgr.ProcessAction(action);

            LogChannel('NTR_MOD', "-----ATTACK ACTION LOG!!!-----");
            LogChannel('NTR_MOD', "GetWeaponId: " + NR_stringById(action.GetWeaponId()) );
            LogChannel('NTR_MOD', "IsParried: " + action.IsParried() );
            LogChannel('NTR_MOD', "IsCountered: " + action.IsCountered() );
            LogChannel('NTR_MOD', "WasDodged: " + action.WasDodged() );
            LogChannel('NTR_MOD', "GetDamageDealt: " + action.GetDamageDealt() );
            LogChannel('NTR_MOD', "GetDamageValueTotal: " + action.GetDamageValueTotal() );
            LogChannel('NTR_MOD', "DAMAGE_NAME_DIRECT: " + action.GetDamageValue(theGame.params.DAMAGE_NAME_DIRECT) );
            LogChannel('NTR_MOD', "DAMAGE_NAME_PHYSICAL: " + action.GetDamageValue(theGame.params.DAMAGE_NAME_PHYSICAL) );
            LogChannel('NTR_MOD', "DAMAGE_NAME_SILVER: " + action.GetDamageValue(theGame.params.DAMAGE_NAME_SILVER) );
            LogChannel('NTR_MOD', "DAMAGE_NAME_SLASHING: " + action.GetDamageValue(theGame.params.DAMAGE_NAME_SLASHING) );
            LogChannel('NTR_MOD', "DAMAGE_NAME_BLUDGEONING: " + action.GetDamageValue(theGame.params.DAMAGE_NAME_BLUDGEONING) );
            LogChannel('NTR_MOD', "GetHitTime: " + action.GetHitTime() );
            LogChannel('NTR_MOD', "GetWeaponSlot: " + action.GetWeaponSlot() );
            LogChannel('NTR_MOD', "GetSoundAttackType: " + action.GetSoundAttackType() );
            LogChannel('NTR_MOD', "GetAttackName: " + action.GetAttackName() );
            LogChannel('NTR_MOD', "GetAttackTypeName: " + action.GetAttackTypeName() );
            LogChannel('NTR_MOD', "GetAttackAnimName: " + action.GetAttackAnimName() );
            

            delete action;
        }
    }

	event OnEquipItemRequested(item : SItemUniqueId, ignoreMount : bool)
	{
		NRD("OnEquipItemRequested: " + inv.GetItemName(item) + ", ignoreMount = " + ignoreMount);
		super.OnEquipItemRequested(item, ignoreMount);
	}

	/*public function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
	{
		if (slot == EES_SilverSword || slot == EES_RangedWeapon) {
			NRD("Equip not allowed!: slot = " + slot);
			return false;
		}
		return super.EquipItemInGivenSlot(item, slot, toHand);
	}*/

	/*public function ProcessCombatActionBuffer() : bool
	{
		var action	 			: EBufferActionType			= this.BufferCombatAction;
		var stage	 			: EButtonStage 				= this.BufferButtonStage;		
		var throwStage			: EThrowStage;		
		var actionResult 		: bool = true;
		var posss : Vector;
		
		
		if( isInFinisher )
		{
			return false;
		}
		
		if ( action != EBAT_SpecialAttack_Heavy )
			specialAttackCamera = false;

		posss = thePlayer.GetWorldPosition();
		LogChannel('NR_DEBUG', "NR_WOMAN:: ProcessCombatActionBuffer( POS = [" + posss.X + ", " + posss.Y + ", " + posss.Z + "])");
		
		if( super.ProcessCombatActionBuffer() ) {
			posss = thePlayer.GetWorldPosition();
			LogChannel('NR_DEBUG', "NR_WOMAN:: SUPER true, POS = [" + posss.X + ", " + posss.Y + ", " + posss.Z + "])");
			return true;		
		}
			
		switch ( action )
		{			
			case EBAT_CastSign :
			{
				switch ( stage )
				{
					case BS_Pressed : 
					{
						actionResult = this.CastSign();
						LogChannel('SignDebug', "CastSign()");
					} break;
					
					default : 
					{
						actionResult = false;
					} break;
				}
			} break;
			
			case EBAT_SpecialAttack_Light :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						actionResult = this.OnPerformSpecialAttack( true, true );
					} break;
					
					case BS_Released :
					{
						actionResult = this.OnPerformSpecialAttack( true, false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;

			case EBAT_SpecialAttack_Heavy :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						
						actionResult = this.OnPerformSpecialAttack( false, true );
					} break;
					
					case BS_Released :
					{
						actionResult = this.OnPerformSpecialAttack( false, false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			
			default:
				return false;	
		}
		
		
		this.CleanCombatActionBuffer();
		
		if (actionResult)
		{
			SetCombatAction( action ) ;
		}

		posss = thePlayer.GetWorldPosition();
		LogChannel('NR_DEBUG', "NR_WOMAN:: itself true ( POS = [" + posss.X + ", " + posss.Y + ", " + posss.Z + "])");
		return true;
	}*/

	/*event OnAnimEvent_item( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) {
		NRD("Anim (event item): " + animEventName + ", type: " + animEventType);
	}

	event OnAnimEvent_TempWrapper( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) {
		NRD("Anim: " + animEventName);
	}*/
	
	/* from Ciri replacer class - fix sliding to target */
	event OnAnimEvent_SlideToTarget( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var minDistance			: float;
		
		if( !HasAbility('Ciri_Rage') )
			return false;
		
		if ( animEventType == AET_DurationStart )
			slideNPC = (CNewNPC)slideTarget;
		
		if ( !slideNPC )
			return false;
		
		if ( VecDistanceSquared(this.GetWorldPosition(),slideNPC.GetWorldPosition()) > 12*12 )
			return false;
		
		if ( animEventType == AET_DurationStart && slideNPC.GetGameplayVisibility() )
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelAll();
			slideTicket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
			movementAdjustor.BindToEventAnimInfo( slideTicket, animInfo );
			
			movementAdjustor.ScaleAnimation( slideTicket );
			minSlideDistance = this.GetRadius() + slideNPC.GetRadius() + 0.01f;
			movementAdjustor.SlideTowards( slideTicket, slideNPC, minSlideDistance, minSlideDistance );					
		}
		else if ( !slideNPC.GetGameplayVisibility() )
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SlideToTarget' );
			slideNPC = NULL;
		}
		else 
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.SlideTowards( slideTicket, slideNPC, minSlideDistance, minSlideDistance );				
		}
	}
}

exec function tr_block(action : EInputActionBlock) {
	thePlayer.BlockAction( action, 'being_NR_ReplacerWoman' );
}
exec function tr_unblock(action : EInputActionBlock) {
	thePlayer.UnblockAction( action, 'being_NR_ReplacerWoman' );
}