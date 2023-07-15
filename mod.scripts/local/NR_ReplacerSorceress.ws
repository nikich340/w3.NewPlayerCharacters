statemachine class NR_ReplacerSorceress extends NR_ReplacerWitcheress {
	public var magicManager 	: NR_MagicManager;
	public var nr_signOwner 	: W3SignOwnerPlayer;
	protected saved var nr_quenEntity 	: NR_SorceressQuen;
	protected saved var nr_lumosActive	: bool;
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
			magicManager.LumosFX(/*enable*/ true);

		NR_RestoreQuen(savedQuenHealth, savedQuenDuration);
	}

	function SetLumosActive(active : bool) {
		NRD("SetLumosActive: " + active);
		nr_lumosActive = active;
	}

	timer function NR_SetTargetDist( delta : float, id : int ) {
		nr_targetDist = 17.f; // TODO: use settings value
		findMoveTargetDistMin = nr_targetDist;
		NRD("NR_SetTargetDist = " + nr_targetDist);
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
	
	// TODO: Remove this later!!
	//event OnAnimEventBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	//{
		//NR_Notify("OnAnimEventBlend:: eventName = " + animEventName + ", animName = " + GetAnimNameFromEventAnimInfo(animInfo));
	//}

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
			nr_quenEntity.GotoState('Expired');
		}
		nr_quenEntity = (NR_SorceressQuen)theGame.CreateEntity( GetSignTemplate(ST_Quen), GetWorldPosition(), GetWorldRotation() );
		return nr_quenEntity.Init( nr_signOwner, GetSignEntity(ST_Quen) );
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

	/*public function IsImmuneToBuff(effect : EEffectType) : bool
	{
		var immunes : CBuffImmunity;
		var i : int;
		var potion, positive, neutral, negative, immobilize, confuse, damage : bool;
		var criticalStatesToResist, resistCriticalStateChance, resistCriticalStateMultiplier : float;
		var localCriticalStateCounter : float;
		var mac : CMovingAgentComponent;
		
		NRD("sorceress.IsImmuneToBuff: " + effect);
		mac = GetMovingAgentComponent();
		
		if ( mac && mac.IsEntityRepresentationForced() == 512 && !IsUsingVehicle() ) 
		{
			if( effect != EET_Snowstorm && effect != EET_SnowstormQ403 )
				return false;
		}
		
		if ( IsCriticalEffectType( effect ) && HasAbility( 'ResistCriticalStates' ) )
		{
			criticalStatesToResist = CalculateAttributeValue( GetAttributeValue( 'critical_states_to_raise_guard' ) );
			resistCriticalStateChance = CalculateAttributeValue( GetAttributeValue( 'resist_critical_state_chance' ) );
			resistCriticalStateMultiplier = CalculateAttributeValue( GetAttributeValue( 'resist_critical_state_chance_mult_per_hit' ) );
			
			localCriticalStateCounter = GetCriticalStateCounter();
			resistCriticalStateChance += localCriticalStateCounter * resistCriticalStateMultiplier;
			
			if ( localCriticalStateCounter >= criticalStatesToResist )
			{
				if( resistCriticalStateChance > RandRangeF( 1, 0 ) )
				{
					NRD("sorceress.IsImmuneToBuff: case 1");
					return true;
				}
			}
		}
		
		for(i=0; i<buffImmunities.Size(); i+=1)
		{
			if(buffImmunities[i].buffType == effect) {
				NRD("sorceress.IsImmuneToBuff: case 2");
				return true;
			}
		}
		
		for(i=0; i<buffRemovedImmunities.Size(); i+=1)
		{
			if(buffRemovedImmunities[i].buffType == effect)
				return false;
		}
		
		immunes = theGame.GetBuffImmunitiesForActor(this);
		if(immunes.immunityTo.Contains(effect)) {
			NRD("sorceress.IsImmuneToBuff: case 3");
			return true;
		}
		
		theGame.effectMgr.GetEffectTypeFlags(effect, potion, positive, neutral, negative, immobilize, confuse, damage);
		if( (potion && immunes.potion) || (positive && immunes.positive) || (neutral && immunes.neutral) || (negative && ( isImmuneToNegativeBuffs || immunes.negative ) ) || (immobilize && immunes.immobilize) || (confuse && immunes.confuse) || (damage && immunes.damage) )
		{
			if (potion && immunes.potion)
				NRD("sorceress.IsImmuneToBuff: case 4a");
			if (positive && immunes.positive)
				NRD("sorceress.IsImmuneToBuff: case 4b");
			if (neutral && immunes.neutral)
				NRD("sorceress.IsImmuneToBuff: case 4c");
			if (negative && ( isImmuneToNegativeBuffs || immunes.negative ) )
				NRD("sorceress.IsImmuneToBuff: case 4d");
			if (immobilize && immunes.immobilize)
				NRD("sorceress.IsImmuneToBuff: case 4e");
			if (confuse && immunes.confuse)
				NRD("sorceress.IsImmuneToBuff: case 4f");
			if (damage && immunes.damage)
				NRD("sorceress.IsImmuneToBuff: case 4g");
			NRD("sorceress.IsImmuneToBuff: case 4");
			return true;
		}
			
		return false;
	}*/

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