statemachine class NR_SorceressQuen extends W3QuenEntity
{
	// change mode on holding button, but don't allow the game to change beh var
	editable var isReallyAlternate 		: Bool;
	editable var playOnOwner 			: Bool;
	editable var cameraShakeStrength 	: float;
	protected var magicManager 			: NR_MagicManager;
	protected var drainStamina, s_counterLightning 	: bool;
	protected var m_cachedEffectName 	: name;
	default playOnOwner = false;
	default cameraShakeStrength = 0.2f;

	default skillEnum = S_Magic_4;

	public function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{
		var player : CR4Player;
		var focus : SAbilityAttributeValue;
		var durationBonus, healthMultiplier : float;
		
		magicManager = NR_GetMagicManager();
		if (!magicManager) {
			return false;
		}
		owner = inOwner;
		fireMode = 0;
		GetSignStats();  // <-- vanilla shieldDuration and shieldHealth here

		durationBonus = magicManager.GetGeneralDurationBonus() + magicManager.GetActionDurationBonus(ENR_SpecialShield);
		healthMultiplier = magicManager.GetShieldDamageAbsorption(); // % of max HP
		shieldDuration = magicManager.GetParamFloat('ST_Universal', "duration_" + ENR_MAToName(ENR_SpecialShield));
		shieldDuration *= (100.f + durationBonus) / 100.f;
		shieldHealth = thePlayer.GetStatMax(BCS_Vitality);
		shieldHealth *= healthMultiplier / 100.f;
		s_counterLightning = magicManager.IsActionAbilityUnlocked(ENR_SpecialShield, "AutoLightning");

		initialShieldHealth = shieldHealth;
		NRD("NR_SorceressQuen Init: shieldDuration = " + shieldDuration + ", initialShieldHealth = " + initialShieldHealth);

		if ( !skipCastingAnimation && !magicManager.HasStaminaForAction(ENR_SpecialShield) ) {
			CleanUp();
			Destroy();
			return false;
		}
		drainStamina = !skipCastingAnimation;

		
		if ( skipCastingAnimation || owner.InitCastSign( this ) )
		{
			if(!notPlayerCast)
			{
				owner.SetCurrentlyCastSign( GetSignType(), this );				
				CacheActionBuffsFromSkill();
			}
			
			if ( !skipCastingAnimation )
			{
				AddTimer( 'BroadcastSignCast', 0.8, false, , , true );
			}
			
			player = (CR4Player)owner.GetPlayer();
			if(player && !notPlayerCast && player.CanUseSkill(S_Perk_10))
			{
				focus = player.GetAttributeValue('focus_gain');
				
				if ( player.CanUseSkill(S_Sword_s20) )
				{
					focus += player.GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * player.GetSkillLevel(S_Sword_s20);
				}
				player.GainStat(BCS_Focus, 0.1f * (1 + CalculateAttributeValue(focus)) );	
			}
			
 			return true;
		}
		else
		{
			owner.GetActor().SoundEvent( "gui_ingame_low_stamina_warning" );
			CleanUp();
			Destroy();
			return false;
		}
	}
	event OnStarted() 
	{
		var isAlternate		: bool;

		// --- owner.ChangeAspect( this, S_Magic_s04 );
		if ( theInput.GetActionValue( 'CastSignHold' ) > 0.f ) {
			// --- signEntity.SetAlternateCast( skillEnum );
			// --- player.SetBehaviorVariable( 'alternateSignCast', 1 );
			isReallyAlternate = true;
		} else {
			isReallyAlternate = false;
			OnNormalCast(); // vibrate light
		}
		isAlternate = IsAlternateCast(); // always false!
		
		if(isAlternate /* false */)
		{
			CreateAttachment( owner.GetActor(), 'quen_sphere' );
		}
		else
		{
			CreateAttachment( owner.GetActor(), , Vector(0,0,0.7f) );
			// --- super.OnStarted();
		}
		
		if(owner.GetActor() == thePlayer)
		{
			if ( ShouldProcessTutorial('TutorialSelectQuen') ) {
				FactsAdd("tutorial_quen_cast");
			}
		}
		
		if((CPlayer)owner.GetActor())
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
				
		GotoState( 'QuenShield' );
	}

	public function LastingShieldFxName() : name {
		return magicManager.SphereHitFxName();
	}

	public function LastingImpulseFxName() : name {
		return magicManager.SphereHitFxName();
	}

	public function DischargeFxName() : name {
		return 'quen_force_discharge';
	}

	public function FxName() : name {
		if (!IsNameValid(m_cachedEffectName))
			m_cachedEffectName = magicManager.SphereFxName();
		return m_cachedEffectName;
	}

	public function FxAltName() : name {
		if (!IsNameValid(m_cachedEffectName))
			m_cachedEffectName = magicManager.SphereFxName();
		return m_cachedEffectName;
	}

	protected function LaunchEffect(enable : bool) {
		var finalName : name;
		if (isReallyAlternate)
			finalName = FxAltName();
		else
			finalName = FxName();

		NRD("LaunchEffect: name = " + finalName + ", playOnOwner = " + playOnOwner + ", enable = " + enable);
		if (playOnOwner) {
			if ( enable )
				owner.GetActor().PlayEffect(finalName);
			else
				owner.GetActor().StopEffect(finalName);
		}
		else {
			if ( enable )
				PlayEffect(finalName);
			else
				StopEffect(finalName);
		}
	}


}

state Expired in NR_SorceressQuen
{
	event OnEnterState( prevStateName : name )
	{
		parent.shieldHealth = 0;
		
		//if(parent.showForceFinishedFX)
		//	parent.owner.GetActor().PlayEffect( parent.LastingShieldFxName(0) );
			
		parent.DestroyAfter( 1.f );		
		
		if(parent.owner.GetActor() == thePlayer)
			theGame.VibrateControllerHard();	
	}
}

state ShieldActive in NR_SorceressQuen extends Active
{	
	protected var attackers : array<CActor>;

	event OnEnterState( prevStateName : name )
	{
		var witcher			: W3PlayerWitcher;
		var params 			: SCustomEffectParams;
		
		super.OnEnterState( prevStateName );
		
		witcher = (W3PlayerWitcher)caster.GetActor();
		
		if(witcher)
		{
			witcher.SetUsedQuenInCombat();
			witcher.m_quenReappliedCount = 1;
			
			params.effectType = EET_BasicQuen;
			params.creator = witcher;
			params.sourceName = "sign cast";
			params.duration = parent.shieldDuration;
			
			witcher.AddEffectCustom( params );
		}

		caster.GetActor().GetMovingAgentComponent().SetVirtualRadius( 'QuenBubble' );
		
		parent.LaunchEffect( true );
		
		parent.AddTimer( 'Expire', parent.shieldDuration, false, , , true );
		
		parent.AddBuffImmunities();
		
		if( witcher )
		{
			if ( parent.drainStamina ) {
				parent.magicManager.DrainStaminaForAction(ENR_SpecialShield);
			} 
			else if( !parent.freeFromBearSetBonus )
			{
				parent.ManagePlayerStamina();
				parent.ManageGryphonSetBonusBuff();
			}
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
		
		
		if( !witcher.IsSetBonusActive( EISB_Bear_1 ) || ( !witcher.HasBuff( EET_HeavyKnockdown ) && !witcher.HasBuff( EET_Knockdown ) ) )
		{
			witcher.CriticalEffectAnimationInterrupted("basic quen cast");
		}
		
		
		witcher.AddTimer('HACK_QuenSaveStatus', 0, true);
		parent.shieldStartTime = theGame.GetEngineTime();
		RunWait();
	}

	entry function RunWait() {
		while (true) {
			SleepOneFrame();

			if (attackers.Size() > 0) {
				PerformAutoLightning(attackers[0]);
				attackers.Erase(0);
			}
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)caster.GetActor();

		parent.LaunchEffect( false );

		if(witcher && parent == witcher.GetSignEntity(ST_Quen))
		{
			witcher.RemoveBuff( EET_BasicQuen );
		}
		witcher.GetMovingAgentComponent().ResetVirtualRadius();
	
		parent.RemoveBuffImmunities();
		
		parent.RemoveHitDoTEntities();
		
		if(parent.owner.GetActor() == thePlayer)
		{
			GetWitcherPlayer().OnBasicQuenFinishing();			
		}
	}
	
	event OnEnded(optional isEnd : bool)
	{
		// --- parent.StopEffect( parent.effects[parent.fireMode].castEffect );
	}
		
	// damageData - after attacking shield
	event OnTargetHit( out damageData : W3DamageAction )
	{
		var pos : Vector;
		var reducedDamage, drainedHealth, skillBonus, incomingDamage, directDamage : float;
		var spellPower : SAbilityAttributeValue;
		var physX : CEntity;
		var inAttackAction : W3Action_Attack;
		var action : W3DamageAction;
		var casterActor : CActor;
		var effectTypes : array < EEffectType >;
		var damageTypes : array<SRawDamage>;
		var i : int;
		var isBleeding : bool;
		
		var min, max : SAbilityAttributeValue; 
		
		// was dodged
		if( damageData.WasDodged() ||
			damageData.GetHitReactionType() == EHRT_Reflect )
		{
			return true;
		}
		
		// notify controller
		parent.OnTargetHit(damageData);
		
		// is parried
		inAttackAction = (W3Action_Attack)damageData;
		if(inAttackAction && inAttackAction.CanBeParried() && (inAttackAction.IsParried() || inAttackAction.IsCountered()) )
			return true;
		
		casterActor = caster.GetActor();
		reducedDamage = 0;

		damageData.GetDTs(damageTypes);
		for(i = 0; i < damageTypes.Size(); i += 1)
		{
			if(damageTypes[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDamage = damageTypes[i].dmgVal;
				break;
			}
		}
		
		
		if( (W3Effect_Bleeding)damageData.causer )
		{
			incomingDamage = directDamage;
			isBleeding = true;
		}
		else
		{	
			isBleeding = false;
			incomingDamage = MaxF(0, damageData.processedDmg.vitalityDamage - directDamage);
		}
		
		if (incomingDamage < parent.shieldHealth) {
			reducedDamage = incomingDamage;
		} else {
			//if (parent.shieldHealth > parent.GetInitialShieldHealth() / parent.minimumAttacksToBlock) {
			//	reducedDamage = incomingDamage;
			//} else {
				reducedDamage = MaxF(incomingDamage, parent.shieldHealth);
			//}
		}
		
		
		if(!damageData.IsDoTDamage())
		{
			casterActor.PlayEffect( parent.LastingShieldFxName() );	
			
			GCameraShake( parent.cameraShakeStrength, true, parent.GetWorldPosition(), 30.0f );
		}
		
		if ( theGame.CanLog() )
		{
			LogDMHits("Quen ShieldActive.OnTargetHit: reducing damage from " + damageData.processedDmg.vitalityDamage + " to " + (damageData.processedDmg.vitalityDamage - reducedDamage), action );
		}
		NRD("SorceressQuen Shield: shieldHealth = " + parent.shieldHealth + ", playerHealthMax = " + thePlayer.GetStatMax(BCS_Vitality) + ", incomingDamage = " + incomingDamage + ", reducedDamage = " + reducedDamage);
		
		damageData.SetHitAnimationPlayType( EAHA_ForceNo );		
		damageData.SetCanPlayHitParticle( false );
		
		if(reducedDamage > 0)
		{
			/*
			if ( parent.wasSignSupercharged )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'magic_s15', 'spell_power', min, max);
				skillBonus = CalculateAttributeValue( min ) * 3;
				skillBonus += CalculateAttributeValue( caster.GetSkillAttributeValue( S_Sword_s19, 'spell_power', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s19 );
			}
			else if ( caster.CanUseSkill( S_Magic_s15 ) )
				skillBonus = CalculateAttributeValue( caster.GetSkillAttributeValue( S_Magic_s15, 'bonus', false, true ) );
			else
				skillBonus = 0;
			
				
			drainedHealth = reducedDamage / (skillBonus + spellPower.valueMultiplicative);			
			parent.shieldHealth -= drainedHealth;
			*/

			//parent.shieldHealth -= MinF(reducedDamage, parent.GetInitialShieldHealth() / parent.minimumAttacksToBlock);
			parent.shieldHealth -= reducedDamage;
			damageData.processedDmg.vitalityDamage -= reducedDamage;
			
			if( damageData.processedDmg.vitalityDamage >= 20 )
				casterActor.RaiseForceEvent( 'StrongHitTest' );
			
			/*
			if (!damageData.IsDoTDamage() && casterActor == thePlayer && damageData.attacker != casterActor && ( GetWitcherPlayer().CanUseSkill(S_Magic_s14) || parent.wasSignSupercharged ) && parent.dischargePercent > 0 && !damageData.IsActionRanged() && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) 
			{
				action = new W3DamageAction in theGame.damageMgr;
				action.Initialize( casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock' );
				parent.InitSignDataForDamageAction( action );		
				action.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * incomingDamage );
				action.SetCanPlayHitParticle(true);
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
				
				theGame.damageMgr.ProcessAction( action );		
				delete action;
				
				casterActor.PlayEffect('quen_force_discharge');
			}
			*/
			// !damageData.IsActionRanged()
			if (parent.s_counterLightning && damageData.attacker != casterActor  && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 25) {
				attackers.PushBack((CActor)damageData.attacker);
			}
		}
		
		
		if(reducedDamage > 0 && (!damageData.DealsAnyDamage() || (isBleeding && reducedDamage >= directDamage)) )
			parent.SetBlockedAllDamage(true);
		else
			parent.SetBlockedAllDamage(false);
		
		
		if( parent.shieldHealth <= 0 )
		{
			/*
			if ( parent.owner.CanUseSkill(S_Magic_s13) || parent.wasSignSupercharged )
			{				
				casterActor.PlayEffect( 'lasting_shield_impulse' );
				if ( parent.wasSignSupercharged )
					caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse", 3 );
				else
					caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
			}
			*/
			casterActor.PlayEffect( parent.LastingImpulseFxName() );
			caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse", 3 );
			
			damageData.SetEndsQuen(true);
		}
	}

	latent function PerformAutoLightning(attacker : CActor) {
		var action : NR_MagicLightning;
		var center, position : Vector;

		if (!attacker)
			return;

		center = thePlayer.GetWorldPosition() + Vector(0.f, 0.f, 1.5f);
		position = center + VecNormalize2D(attacker.GetWorldPosition() - thePlayer.GetWorldPosition()) * 0.3f;
		action = new NR_MagicLightning in parent.magicManager;
		action.drainStaminaOnPerform = false;
		parent.magicManager.AddActionManual(action);
		action.target = attacker;
		action.OnInit();
		action.OnPrepare();
		action.m_fxNameMain = action.LightningFxName(ENR_SpecialShield);
		action.m_fxNameHit = action.HitFxName(ENR_SpecialShield);
		action.OnPerformReboundFromPos(attacker, position);
		action.OnPerformed(true, true);
	}
}
