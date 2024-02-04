class NR_MagicSpecialShield extends NR_MagicAction {
	default isDamaging 	= false;
	default performsToLevelup = 50; // action-specific
	default actionType = ENR_SpecialShield;
	default actionSubtype = ENR_SpecialAbstract;
	default drainStaminaOnPerform = false; // drained in NR_SorceressQuen

	latent function OnInit() : bool {
		sceneInputs.PushBack(22);
		sceneInputs.PushBack(23);
		sceneInputs.PushBack(24);
		sceneInputs.PushBack(25);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("AutoLightning");
		}
		if (newLevel == 8) {
			ActionAbilityUnlock("AutoCombatApply");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();
		return OnPrepared(true);
	}
	
	// NOTE: see NR_SorceressQuen, main stuff there
	latent function OnPerform() : bool {
		m_fxNameMain = NR_GetMagicManager().SphereFxName();

		if ( IsInSetupScene() ) {
			thePlayer.PlayEffect( m_fxNameMain );
			Sleep( 2.5f );
			thePlayer.StopEffect( m_fxNameMain );
		}
		return OnPerformed(true);
	}
}
