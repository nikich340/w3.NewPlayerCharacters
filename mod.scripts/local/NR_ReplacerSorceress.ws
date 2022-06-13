statemachine class NR_ReplacerSorceress extends NR_ReplacerWitcheress {
	public var testMan 	 	: NR_TestManager;
	public var magicMan 	 : NR_MagicManager;
	public var nr_signOwner : W3SignOwnerPlayer;

	default replacerName      = "nr_replacer_sorceress";
	default inventoryTemplate = "nr_replacer_sorceress_inv";

	// --- remove guarded stance
	public function SetGuarded(flag : bool)
	{
		NR_Notify("SetGuarded1: " + flag);
		//super.SetGuarded(flag);
	}

	/*public function ProcessCombatActionBuffer() : bool
	{
		var action	 			: EBufferActionType			= this.BufferCombatAction;
		var stage	 			: EButtonStage 				= this.BufferButtonStage;		
		var throwStage			: EThrowStage;		
		var actionResult 		: bool = true;
		
		NR_Notify("ProcessCombatActionBuffer:: action = " + action + ", stage = " + stage);
		return super.ProcessCombatActionBuffer();
	}*/

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		magicMan = new NR_MagicManager in this;
		magicMan.InitDefaults();
		magicMan.GotoState('MagicLoop');
		//testMan = new NR_TestManager in this;
		//testMan.GotoState('Latent');

		super.OnSpawned( spawnData );
		AddAnimEventCallback('AllowBlend',	'OnAnimEventBlend');

		// no swords
		BlockAction( EIAB_DrawWeapon, 'NR_ReplacerSorceress' );
		// no guard poses
		super.SetGuarded(false);
		// signOwner is private in W3PlayerWitcher..
		nr_signOwner = new W3SignOwnerPlayer in this;
		nr_signOwner.Init( this );
	}
	event OnAnimEventBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		NR_Notify("OnAnimEventBlend:: eventName = " + animEventName + ", animName = " + GetAnimNameFromEventAnimInfo(animInfo));
	}

	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool {
		var magicEvent : SNR_MagicEvent;
		var effectInfos : array< SEffectInfo >;

        if (damageAction.GetEffects( effectInfos ) > 0 || damageAction.DealsAnyDamage()) {
        	magicEvent.eventName = 'BreakMagicAttack';
        	magicMan.aEventsStack.PushBack(magicEvent);
        	PrintDamageAction("ReactToBeingHit", damageAction);
        }
        NR_Notify("ReactToBeingHit, damage = " + damageAction.DealsAnyDamage());
        
        return super.ReactToBeingHit(damageAction);
	}
	public function ReactToReflectedAttack( target : CGameplayEntity)
	{
		NRD("BLOCK ReactToReflectedAttack!");
		// --- super.ReactToReflectedAttack(target);
	}

	function SetEquippedSign( signType : ESignType )
	{
		//NR_Notify("Selected sign: " + signType);
		super.SetEquippedSign(signType);

		// must be processed in sync
		magicMan.HandFX(true, true);
	}

	// tmp!
	/*public function ApplyActionEffects( action : W3DamageAction ) : bool
	{
		NRD("ApplyActionEffects: action causer = " + action.causer);

		if(effectManager)
			return effectManager.AddEffectsFromAction( action );
			
		return false;
	}*/

	/*protected function prepareAttackAction( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity, out attackAction : W3Action_Attack) : bool
	{
		var ret : Bool;
		ret = super.PrepareAttackAction(hitTarget, animData, weaponId, parried, countered, parriedBy, 
			attackAnimationName, hitTime, weaponEntity, attackAction);

		// Avoid reflecting damage (it's not really fistfight)
		attackAction.SetCannotReturnDamage( true );
		return ret;
	}*/

	function CastSign() : bool
	{
		var sign : ESignType;
		sign = GetWitcherPlayer().GetEquippedSign();
		NR_Notify("CastSign(): " + sign);
		GotoCombatStateWithAction( IA_None );

		switch (sign) {
			case ST_Quen:
				return super.CastSign();
			default:
				return OnPerformAttack('attack_magic_special');
		}
	}

	/*public function QuenImpulse( isAlternate : bool, signEntity : W3QuenEntity, source : string, optional forceSkillLevel : int )
	{
		NR_Notify("QuenImpulse: source = " + source);
		super.QuenImpulse(isAlternate, signEntity, source, forceSkillLevel);
	}*/

	public function CanUseSkill(skill : ESkill) : bool
	{
		if (skill == S_Magic_4 || skill == S_Magic_s14 || skill == S_Magic_s13 || skill == S_Magic_s01) // quen bubble, reflect, impulse, aard circle =  || skill == S_Magic_s06
			return true;

		return super.CanUseSkill(skill);
	}
	/*public function HasBuff(effectType : EEffectType) : bool
	{
		if( effectType == EET_Mutation11Buff )
			return true;
			
		return super.HasBuff(effectType);
	}*/
}

function NR_GetReplacerSorceress() : NR_ReplacerSorceress
{
	return (NR_ReplacerSorceress)thePlayer;
}

function NR_GetMagicManager() : NR_MagicManager
{
	var sorceress : NR_ReplacerSorceress;
	sorceress = NR_GetReplacerSorceress();
	return sorceress.magicMan;
}
