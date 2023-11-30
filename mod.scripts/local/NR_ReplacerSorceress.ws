statemachine class NR_ReplacerSorceress extends NR_ReplacerWitcheress {
	public var magicManager 	: NR_MagicManager;
	public var nr_signOwner 	: W3SignOwnerSorceress;
	protected saved var nr_quenEntity 	: NR_SorceressQuen;
	protected saved var nr_lumosActive	: bool;
	protected saved var nr_lumosFxName	: name;
	protected var nr_targetDist : float;

	default nr_lumosActive 	  = false;
	default m_replacerType    = ENR_PlayerSorceress;
	default inventoryTemplate = "nr_replacer_sorceress_inv";

	/* Remove guarded stance - sorceress never use real fistfight */
	public function SetGuarded(flag : bool)
	{
		// --- super.SetGuarded(flag);
	}

	public function GetNameID() : int {
		return 358190; // 0000358190|e29b1c4b|-1.000|Sorceress
	}

	public function NR_IsSlotDenied(slot : EEquipmentSlots) : bool
	{
		if (slot == EES_SilverSword || slot == EES_SteelSword || slot == EES_Potion4)
			return true;

		return super.NR_IsSlotDenied(slot);
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );

		magicManager = new NR_MagicManager in this;
		AddTimer('NR_LaunchMagicManager', 0.25f);  // post-pone to let player manager load

		AddAnimEventCallback('AllowBlend',	'OnAnimEventBlend'); // TODO: Remove this later!!

		// no swords
		BlockAction( EIAB_DrawWeapon, 'NR_ReplacerSorceress' );
		ExterminateSwordStuff();
		
		// no guard poses
		super.SetGuarded(false);
		
		// signOwner is private in W3PlayerWitcher.. add our own!
		nr_signOwner = new W3SignOwnerSorceress in this;
		nr_signOwner.Init( this );

		NR_SetTargetDist( 0.0, 0 );
		softLockDist = nr_targetDist * 1.25;
		findMoveTargetDistMax = nr_targetDist + 10.f;
	}

	timer function NR_LaunchMagicManager( delta : float, id : int) {
		magicManager.Init();
		magicManager.GotoState('MagicLoop');
		// launch lumos fx if was active
		if (nr_lumosActive) {
			magicManager.LumosFX(/*enable*/ true, nr_lumosFxName);
		}
		NRD("Sorceress.NR_LaunchMagicManager: nr_lumosActive = " + nr_lumosActive);

		NR_RestoreQuen(savedQuenHealth, savedQuenDuration);
	}

	function SetLumosActive(active : bool, fxName : name) {
		NRD("SetLumosActive: " + active);
		nr_lumosActive = active;
		nr_lumosFxName = fxName;
	}

	timer function NR_SetTargetDist( delta : float, id : int ) {
		nr_targetDist = 15.f;
		findMoveTargetDistMin = nr_targetDist;
		NRD("NR_SetTargetDist = " + nr_targetDist);
	}

	public function ExterminateSwordStuff() {
		var i 	: int;
		var ids : array<SItemUniqueId>;

		UnequipItemFromSlot(EES_SteelSword);
		UnequipItemFromSlot(EES_SilverSword);
		UnequipItemFromSlot(EES_Potion4);

		inv.GetAllItems(ids);
		for (i = 0; i < ids.Size(); i += 1) {
			if (inv.GetItemCategory(ids[i]) == 'steelsword' || inv.GetItemCategory(ids[i]) == 'silversword'
				|| inv.GetItemCategory(ids[i]) == 'steel_scabbards' || inv.GetItemCategory(ids[i]) == 'silver_scabbards') 
			{
				if ( inv.IsItemHeld(ids[i]) )
					inv.DropItem(ids[i], false);
				if ( inv.IsItemMounted(ids[i]) )
					inv.UnmountItem(ids[i]);
				if ( IsItemEquipped(ids[i]) )
					UnequipItem(ids[i]);
			}
		}

		weaponHolster.UpdateRealWeapon();
	}

	event OnAnimEventMagic( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if (animEventType != AET_Tick) {
			return false;
		}
		//magicEvent.animTime = GetLocalAnimTimeFromEventAnimInfo(animInfo);
		//magicEvent.eventDuration = GetEventDurationFromEventAnimInfo(animInfo);
		NRD("OnAnimEventMagic:: eventName = " + animEventName + ", type = " + animEventType + ", animName = " + GetAnimNameFromEventAnimInfo(animInfo));
		// will be auto-processed async in next frame
		magicManager.AddActionEvent( animEventName, GetAnimNameFromEventAnimInfo(animInfo) );
	}

	event OnPreAttackEvent(animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo)
	{
		if (animEventType == AET_DurationStart) {
			// must be processed in sync to change data var
			magicManager.OnPreAttackEvent(GetAnimNameFromEventAnimInfo(animInfo), data);
		}
		super.OnPreAttackEvent(animEventName, animEventType, data, animInfo);
	}

	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		ExterminateSwordStuff();
		if (output.action == SSOA_EnterCombatSteel || output.action == SSOA_EnterCombatSilver)
			output.action = SSOA_EnterCombatFists;
		super.OnBlockingSceneEnded( output );
	}
	
	public function GoToStateIfNew( newState : name, optional keepStack : bool, optional forceEvents : bool  )
	{
		NRD("GoToStateIfNew: newState = " + newState);
		super.GoToStateIfNew(newState, keepStack, forceEvents);
	}

	// TODO: Remove this later!!
	event OnAnimEventBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		//NR_Notify("OnAnimEventBlend: (" + animEventName + ") " + GetAnimNameFromEventAnimInfo(animInfo));
	}

	public function NR_RestoreQuen( quenHealth : float, quenDuration : float ) : bool
	{
		NRD("NR_RestoreQuen: quenHealth = " + quenHealth + ", quenDuration = " + quenDuration);
		if(quenHealth > 0.f && quenDuration >= 3.f)
		{
			if (!nr_quenEntity) {
				nr_quenEntity = (NR_SorceressQuen)theGame.CreateEntity( GetSignTemplate(ST_Quen), GetWorldPosition(), GetWorldRotation() );
				NRD("NR_RestoreQuen: recreate entity");
			}
			
			nr_quenEntity.Init( nr_signOwner, GetSignEntity(ST_Quen), true );
			
			nr_quenEntity.SetDataFromRestore(quenHealth, quenDuration);
			nr_quenEntity.OnStarted();
			nr_quenEntity.OnThrowing();
			nr_quenEntity.OnEnded();
			
			return true;
		}
		
		return false;
	}

	/* Break current magic attack, if it's in process */
	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool {
		var effectInfos : array< SEffectInfo >;
		var isGameplayEffect : bool;

		if ( (CBaseGameplayEffect)damageAction.causer )
        	isGameplayEffect = true;

        // damageAction.GetBuffSourceName() != "petard"
        if ( !isGameplayEffect && (damageAction.GetEffects( effectInfos ) > 0 || damageAction.DealsAnyDamage()) ) {
        	NRD("ReactToBeingHit: buffSourceName = " + damageAction.GetBuffSourceName() + ", attacker = " + damageAction.attacker + ", causer = " + damageAction.causer);
        	magicManager.AddActionEvent('BreakMagicAttack', 'ReactToBeingHit');
        	//PrintDamageAction("ReactToBeingHit", damageAction);
        }
        //NRD("ReactToBeingHit, damage = " + damageAction.DealsAnyDamage());
        
        return super.ReactToBeingHit(damageAction);
	}
	
	/* All sorceress attacks are made from distance - never allow reflected damage! */
	public function ReactToReflectedAttack( target : CGameplayEntity)
	{
		// --- super.ReactToReflectedAttack(target);
	}

	/* Wrapper: process hand fx change immediately */
	function SetEquippedSign( signType : ESignType )
	{
		super.SetEquippedSign(signType);
		magicManager.HandFX(true, true);
	}

	public function GotoCombatStateWithDodge( bufferAction : EBufferActionType )
	{
		thePlayer.GotoCombatStateWithAction( IA_None );
		thePlayer.EvadePressed( bufferAction );
	}

	public function GotoCombatStateWithAttack( attackName : name )
	{
		thePlayer.GotoCombatStateWithAction( IA_None );
		OnPerformAttack( attackName );
	}

	/* Function to really cast Quen (when we are sure that attack is not alternate) */
	public function CastQuen() : bool
	{
		NRD("CastQuen()");
		/* make standart Quen launching to use vanilla logic */
		SetBehaviorVariable('NR_isMagicAttack', 1);
		
		if ( IsInAir() )
		{
			return false;
		}
		
		//AddTemporarySkills();

		// destroy old shield
		if (nr_quenEntity) {
			NRD("Destroy old quen = " + nr_quenEntity);
			nr_quenEntity.GotoState('Expired');
			nr_quenEntity.DestroyAfter(5.f);
		}
		nr_quenEntity = (NR_SorceressQuen)theGame.CreateEntity( GetSignTemplate(ST_Quen), GetWorldPosition(), GetWorldRotation() );
		return nr_quenEntity.Init( nr_signOwner, GetSignEntity(ST_Quen) );
	}

	/* Wrapper: call fistfight attack */
	function CastSign() : bool
	{
		if ( IsUsingHorse() ) {
			return super.CastSign();
		}
		NRD("CastSign()");
		GotoCombatStateWithAction( IA_None );
		return OnPerformAttack('attack_magic_special');
	}

	/* Wrapper: fool stamina checking when "casting signs" */
	public function HasStaminaToUseSkill(skill : ESkill, optional perSec : bool, optional signHack : bool) : bool
	{
		//NRD("sorceress.HasStaminaToUseSkill: skill = " + skill + ", perSec = " + perSec);
		if (skill >= S_Magic_1 && skill <= S_Magic_5 )
			return true;

		return super.HasStaminaToUseSkill(skill, perSec, signHack);
	}

	/* Wrapper: fool skill checking about some skills */
	public function CanUseSkill(skill : ESkill) : bool
	{
		// 			quen bubble,              quen reflect,           quen impulse,         aard circle
		if (skill == S_Magic_4 || skill == S_Magic_s14 || skill == S_Magic_s13 || skill == S_Magic_s01) 
			return true;

		return super.CanUseSkill(skill);
	}

	public function NR_RotateTowardsNode( customRotationName : name, target : CNode, rotSpeed : float, optional activeTime : float )
	{
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
	
		movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
		ticket = movementAdjustor.GetRequest( customRotationName );
		if ( movementAdjustor.IsRequestActive(ticket) )
			movementAdjustor.Cancel( ticket );

		ticket = movementAdjustor.CreateNewRequest( customRotationName );
		movementAdjustor.ReplaceRotation( ticket );
		movementAdjustor.RotateTowards( ticket, target );

		if (rotSpeed > 0.f) {
			movementAdjustor.MaxRotationAdjustmentSpeed( ticket, rotSpeed );
			movementAdjustor.AdjustmentDuration( ticket, activeTime );
		} else {
			movementAdjustor.Continuous( ticket );
			movementAdjustor.KeepActiveFor( ticket, activeTime );
		}
	}

	public function NR_RotateToHeading( customRotationName : name, targetHeading : float, rotSpeed : float, optional activeTime : float )
	{
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
	
		movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
		ticket = movementAdjustor.GetRequest( customRotationName );
		if ( movementAdjustor.IsRequestActive(ticket) )
			movementAdjustor.Cancel( ticket );

		ticket = movementAdjustor.CreateNewRequest( customRotationName );
		movementAdjustor.ReplaceRotation( ticket );
		movementAdjustor.RotateTo( ticket, targetHeading );
		
		if (rotSpeed > 0.f) {
			movementAdjustor.MaxRotationAdjustmentSpeed( ticket, rotSpeed );
			movementAdjustor.AdjustmentDuration( ticket, activeTime );
		} else {
			movementAdjustor.Continuous( ticket );
			movementAdjustor.KeepActiveFor( ticket, activeTime );
		}
	}
}

function NR_GetReplacerSorceress() : NR_ReplacerSorceress
{
	return (NR_ReplacerSorceress)thePlayer;
}

function NR_GetMagicManager() : NR_MagicManager
{
	var sorceress : NR_ReplacerSorceress;
	sorceress = NR_GetReplacerSorceress();
	return sorceress.magicManager;
}

exec function reset_magic() {
	var manager : NR_MagicManager = NR_GetMagicManager();
	if (!manager) {
		NRE("!magicManager");
	}
	manager.Init(/*forceReset*/ true);
}
