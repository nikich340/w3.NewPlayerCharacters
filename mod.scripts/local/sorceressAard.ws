statemachine class NR_SorceressAard extends W3AardEntity
{
	public function NR_Init( inOwner : W3SignOwner ) : bool
	{
		var player : CR4Player;
		var focus : SAbilityAttributeValue;
		var witcher: W3PlayerWitcher;
		var StaminaCost : float;
		
		owner = inOwner;				// set owner for correct buff!
		fireMode = 0;
		GetSignStats(); 				// does nothing
		CacheActionBuffsFromSkill();	// loads sign buffs to damage action!		

		// FOCUS ?
		/*player = (CR4Player)owner.GetPlayer();
		if(player && player.CanUseSkill(S_Perk_10))
		{
			focus = player.GetAttributeValue('focus_gain');
			
			if ( player.CanUseSkill(S_Sword_s20) )
			{
				focus += player.GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * player.GetSkillLevel(S_Sword_s20);
			}
			player.GainStat(BCS_Focus, 0.1f * (1 + CalculateAttributeValue(focus)) );	
		}*/

		StaminaCost = thePlayer.GetStatMax( BCS_Stamina ) * 30.f / 100.f;

		if (owner.GetActor().GetStat(BCS_Stamina) < StaminaCost) {
			witcher = (W3PlayerWitcher)owner.GetPlayer();
			if (witcher) {
				witcher.SoundEvent( "gui_ingame_low_stamina_warning" );
				witcher.SetShowToLowStaminaIndication(StaminaCost);
			}
			
			// ? CleanUp();
			Destroy();
			return false;
		}
		NRD("NR_SorceressAard StaminaCost = " + StaminaCost);
		NRD("NR_SorceressAard BCS_Stamina = " + thePlayer.GetStat( BCS_Stamina ));
		NRD("NR_SorceressAard BCS_Stamina MAX = " + thePlayer.GetStatMax( BCS_Stamina ));

		thePlayer.DrainStamina(/*type*/ ESAT_FixedValue, /*fixed cost*/ StaminaCost, /*fixed delay*/ 3.f,  /*ability name*/ 'nr_sorceress_aard');
		NRD("NR_SorceressAard BCS_Stamina 2 = " + thePlayer.GetStat( BCS_Stamina ));
		AddTimer( 'BroadcastSignCast', 0.5, false, , , true ); // makes NPC fear!

		return true;
		
		/* ON fail ?
		{
			owner.GetActor().SoundEvent( "gui_ingame_low_stamina_warning" );
			CleanUp();
			Destroy();
			return false;
		}*/
	}

	public function PUBLIC_CacheActionBuffsFromSkill() {
		
		//CacheActionBuffsFromSkill();

		var attrs : array< name >;
		var i, size : int;
		var signAbilityName : name;
		var dm : CDefinitionsManagerAccessor;
		var buff : SEffectInfo;
		
		NR_Notify("PUBLIC_CacheActionBuffsFromSkill");
		NR_Notify("PUBLIC_CacheActionBuffsFromSkill, skillEnum = " + skillEnum);
		actionBuffs.Clear();
		dm = theGame.GetDefinitionsManager();
		if (!owner) {
			NR_Notify("PUBLIC_CacheActionBuffsFromSkill: owner!!");
		}
		signAbilityName = owner.GetSkillAbilityName( skillEnum );

		dm.GetContainedAbilities( signAbilityName, attrs );
		size = attrs.Size();
		NRD("PUBLIC_CacheActionBuffsFromSkill: signAbilityName = " + signAbilityName + ", size = " + size);
		
		for( i = 0; i < size; i += 1 )
		{
			NRD("PUBLIC_CacheActionBuffsFromSkill: attrs[" + i + "] = " + attrs[i]);
			if( IsEffectNameValid(attrs[i]) )
			{
				EffectNameToType(attrs[i], buff.effectType, buff.effectAbilityName);
				NRD("PUBLIC_CacheActionBuffsFromSkill: buff.effectType = " + buff.effectType + ", buff.effectAbilityName = " + buff.effectAbilityName);
				actionBuffs.PushBack(buff);
			}		
		}
	}
}