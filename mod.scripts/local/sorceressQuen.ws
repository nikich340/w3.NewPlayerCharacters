statemachine class NR_SorceressQuen extends W3QuenEntity
{
	// change mode on holding button, but don't allow the game to change beh var
	var isReallyAlternate : Bool;

	// make data simpler
	var effectName, alternateEffectName : name;
	var playOnOwner : Bool;
	var shakeStrength : float;
	default playOnOwner = false;
	default shakeStrength = 0.2f;

	default skillEnum = S_Magic_4;

	event OnStarted() 
	{
		var isAlternate		: bool;
		var witcherOwner	: W3PlayerWitcher;
		var sorceressOwner  : NR_ReplacerSorceress;
		
		witcherOwner = owner.GetPlayer();
		sorceressOwner = (NR_ReplacerSorceress)witcherOwner;
		// --- owner.ChangeAspect( this, S_Magic_s04 );
		if ( theInput.GetActionValue( 'CastSignHold' ) > 0.f ) {
			// --- signEntity.SetAlternateCast( skillEnum );
			// --- player.SetBehaviorVariable( 'alternateSignCast', 1 );
			isReallyAlternate = true;
		} else {
			isReallyAlternate = false;
			OnNormalCast(); // vibrate light
		}
		if (sorceressOwner) {
			sorceressOwner.magicMan.alternateCast = isReallyAlternate;
		}
		isAlternate = IsAlternateCast(); // always false!
		
		if(isAlternate)
		{
			CreateAttachment( owner.GetActor(), 'quen_sphere' );
		}
		else
		{
			CreateAttachment( owner.GetActor(), , Vector(0,0,0.7f) );
			// --- super.OnStarted();
		}
		
		
		if(owner.GetActor() == thePlayer && ShouldProcessTutorial('TutorialSelectQuen'))
		{
			FactsAdd("tutorial_quen_cast");
		}
		
		if((CPlayer)owner.GetActor())
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
				
		GotoState( 'QuenShield' );
	}

	protected function DoEffect(enable : bool) {
		var finalName : name;
		if (isReallyAlternate)
			finalName = alternateEffectName;
		else
			finalName = effectName;

		NR_Notify("DoEffect: name = " + finalName + ", playOnOwner = " + playOnOwner + ", enable = " + enable);
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
		//	parent.owner.GetActor().PlayEffect('quen_lasting_shield_hit');
			
		parent.DestroyAfter( 1.f );		
		
		if(parent.owner.GetActor() == thePlayer)
			theGame.VibrateControllerHard();	
	}
}

state ShieldActive in NR_SorceressQuen extends Active
{	
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
		
		parent.DoEffect( true );
		
		parent.AddTimer( 'Expire', parent.shieldDuration, false, , , true );
		
		parent.AddBuffImmunities();
		
		if( witcher )
		{
			if( !parent.freeFromBearSetBonus )
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
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)caster.GetActor();

		parent.DoEffect( false );

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
		
		if( damageData.WasDodged() ||
			damageData.GetHitReactionType() == EHRT_Reflect )
		{
			return true;
		}
		
		parent.OnTargetHit(damageData);

		inAttackAction = (W3Action_Attack)damageData;
		if(inAttackAction && inAttackAction.CanBeParried() && (inAttackAction.IsParried() || inAttackAction.IsCountered()) )
			return true;
		
		casterActor = caster.GetActor();
		reducedDamage = 0;		
				
		damageData.GetDTs(damageTypes);
		for(i=0; i<damageTypes.Size(); i+=1)
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
		
		if(incomingDamage < parent.shieldHealth)
			reducedDamage = incomingDamage;
		else
			reducedDamage = MaxF(incomingDamage, parent.shieldHealth);
		
		
		if(!damageData.IsDoTDamage())
		{
			casterActor.PlayEffect( 'quen_lasting_shield_hit' );	

			GCameraShake( parent.shakeStrength, true, parent.GetWorldPosition(), 30.0f );
		}
		
		
		if ( theGame.CanLog() )
		{
			LogDMHits("Quen ShieldActive.OnTargetHit: reducing damage from " + damageData.processedDmg.vitalityDamage + " to " + (damageData.processedDmg.vitalityDamage - reducedDamage), action );
		}
		
		damageData.SetHitAnimationPlayType( EAHA_ForceNo );		
		damageData.SetCanPlayHitParticle( false );
		
		if(reducedDamage > 0)
		{
			
			spellPower = casterActor.GetTotalSignSpellPower(virtual_parent.GetSkill());
			
			if ( caster.CanUseSkill( S_Magic_s15 ) )
				skillBonus = CalculateAttributeValue( caster.GetSkillAttributeValue( S_Magic_s15, 'bonus', false, true ) );
			else
				skillBonus = 0;
				
			drainedHealth = reducedDamage / (skillBonus + spellPower.valueMultiplicative);			
			parent.shieldHealth -= drainedHealth;
			
				
			damageData.processedDmg.vitalityDamage -= reducedDamage;
			
			
			if( damageData.processedDmg.vitalityDamage >= 20 )
				casterActor.RaiseForceEvent( 'StrongHitTest' );
				
			
			if (!damageData.IsDoTDamage() && casterActor == thePlayer && damageData.attacker != casterActor && GetWitcherPlayer().CanUseSkill(S_Magic_s14) && parent.dischargePercent > 0 && !damageData.IsActionRanged() && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) 
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
		}
		
		
		if(reducedDamage > 0 && (!damageData.DealsAnyDamage() || (isBleeding && reducedDamage >= directDamage)) )
			parent.SetBlockedAllDamage(true);
		else
			parent.SetBlockedAllDamage(false);
		
		
		if( parent.shieldHealth <= 0 )
		{
			if ( parent.owner.CanUseSkill(S_Magic_s13) )
			{				
				casterActor.PlayEffect( 'lasting_shield_impulse' );
				caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
			}
			
			damageData.SetEndsQuen(true);
		}
	}
}