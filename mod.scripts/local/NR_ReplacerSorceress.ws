statemachine class NR_ReplacerSorceress extends NR_ReplacerWitcheress {
	public var magicManager 	: NR_MagicManager;
	public var nr_signOwner 	: W3SignOwnerPlayer;
	protected saved var nr_lumosActive	: bool;
	protected var nr_targetDist : float;

	default nr_lumosActive 	  = false;
	default m_replacerType    = ENR_PlayerSorceress;
	default inventoryTemplate = "nr_replacer_sorceress_inv";

	/* Remove guarded stance - sorceress never use real fistfight */
	public function SetGuarded(flag : bool)
	{
		NR_Notify("SetGuarded1: " + flag);
		// --- super.SetGuarded(flag);
	}

	public function GetNameID() : int {
		return 358190; // 0000358190|e29b1c4b|-1.000|Sorceress
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );

		magicManager = new NR_MagicManager in this;
		AddTimer('NR_LaunchMagicManager', 0.25f);  // post-pone to let player manager load

		AddAnimEventCallback('AllowBlend',	'OnAnimEventBlend'); // TODO: Remove this later!!
		// no swords
		BlockAction( EIAB_DrawWeapon, 'NR_ReplacerSorceress' );
		
		// no guard poses
		super.SetGuarded(false);
		
		// signOwner is private in W3PlayerWitcher.. add our own!
		nr_signOwner = new W3SignOwnerPlayer in this;
		nr_signOwner.Init( this );

		NR_SetTargetDist( 0.0, 0 );
		softLockDist = nr_targetDist * 1.25;
		findMoveTargetDistMax = nr_targetDist + 10.f;
	}

	timer function NR_LaunchMagicManager( delta : float, id : int) {
		magicManager.Init();
		magicManager.GotoState('MagicLoop');
		// launch lumos fx if was active
		if (nr_lumosActive)
			magicManager.LumosFX(/*enable*/ true, /*reload*/ true);
	}

	function SetLumosActive(active : bool) {
		NR_Notify("SetLumosActive: " + active);
		nr_lumosActive = active;
	}

	timer function NR_SetTargetDist( delta : float, id : int ) {
		nr_targetDist = 17.f; // TODO: use settings value
		findMoveTargetDistMin = nr_targetDist;
		NRD("NR_SetTargetDist");
	}

	event OnAnimEventMagic( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var magicEvent : SNR_MagicEvent;

		if (animEventType != AET_Tick) {
			NRD("ERROR! Wrong animEventType: " + animEventType);
			return false;
		}
		magicEvent.eventName = animEventName;
		magicEvent.animName = GetAnimNameFromEventAnimInfo(animInfo);
		magicEvent.animTime = GetLocalAnimTimeFromEventAnimInfo(animInfo);
		//magicEvent.eventDuration = GetEventDurationFromEventAnimInfo(animInfo);
		NRD("OnAnimEventMagic:: eventName = " + magicEvent.eventName + ", type = " + animEventType + ", animName = " + magicEvent.animName);
		// will be auto-processed async in next frame
		magicManager.aEventsStack.PushBack(magicEvent);
	}

	event OnPreAttackEvent(animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo)
	{
		if (animEventType == AET_DurationStart) {
			// must be processed in sync to change data var
			magicManager.OnPreAttackEvent(GetAnimNameFromEventAnimInfo(animInfo), data);
		}
		super.OnPreAttackEvent(animEventName, animEventType, data, animInfo);
	}
	
	// TODO: Remove this later!!
	//event OnAnimEventBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	//{
		//NR_Notify("OnAnimEventBlend:: eventName = " + animEventName + ", animName = " + GetAnimNameFromEventAnimInfo(animInfo));
	//}

	/* Break current magic attack, if it's in process */
	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool {
		var magicEvent : SNR_MagicEvent;
		var effectInfos : array< SEffectInfo >;

        if (damageAction.GetEffects( effectInfos ) > 0 || damageAction.DealsAnyDamage()) {
        	magicEvent.eventName = 'BreakMagicAttack';
        	magicManager.aEventsStack.PushBack(magicEvent);
        	PrintDamageAction("ReactToBeingHit", damageAction);
        }
        NR_Notify("ReactToBeingHit, damage = " + damageAction.DealsAnyDamage());
        
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
		thePlayer.EvadePressed(EBAT_Dodge);
	}

	/* Function to really cast Quen (when we are sure that attack is not alternate) */
	public function CastQuen() : bool
	{
		NRD("CastQuen()");
		/* make standart Quen launching to use vanilla logic */
		SetBehaviorVariable('NR_isMagicAttack', 1) ;
		return super.CastSign();
	}

	/* Wrapper: call fistfight attack */
	function CastSign() : bool
	{
		NRD("CastSign()");
		GotoCombatStateWithAction( IA_None );
		return OnPerformAttack('attack_magic_special');
	}

	// TODO: Why is it here?
	/*public function QuenImpulse( isAlternate : bool, signEntity : W3QuenEntity, source : string, optional forceSkillLevel : int )
	{
		NR_Notify("QuenImpulse: source = " + source);
		super.QuenImpulse(isAlternate, signEntity, source, forceSkillLevel);
	}*/

	/* Wrapper: fool skill checking about some skills */
	public function CanUseSkill(skill : ESkill) : bool
	{
		if (skill == S_Magic_4 || skill == S_Magic_s14 || skill == S_Magic_s13 || skill == S_Magic_s01) 
		// 			quen bubble,              quen reflect,           quen impulse,         aard circle
			return true;

		return super.CanUseSkill(skill);
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