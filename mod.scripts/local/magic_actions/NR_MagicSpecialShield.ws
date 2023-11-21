class NR_MagicSpecialShield extends NR_MagicAction {
	default actionType = ENR_SpecialShield;
	default actionSubtype = ENR_SpecialAbstract;
	default drainStaminaOnPerform = false; // drained in NR_SorceressQuen

	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 40);

		if ( voicelineChance >= NR_GetRandomGenerator().nextRange(1, 100) ) {
			NRD("PlayScene!");
			sceneInputs.PushBack(22);
			sceneInputs.PushBack(23);
			sceneInputs.PushBack(24);
			sceneInputs.PushBack(25);
			PlayScene( sceneInputs );
		}

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("AutoLightning");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();
		return OnPrepared(true);
	}
	
	// NOTE: see NR_SorceressQuen, main stuff there
	latent function OnPerform(optional scriptedPerform : bool) : bool {
		m_fxNameMain = NR_GetMagicManager().SphereFxName();

		if ( IsInSetupScene() ) {
			thePlayer.PlayEffect( m_fxNameMain );
			Sleep( 2.5f );
			thePlayer.StopEffect( m_fxNameMain );
		}
		return OnPerformed(true, scriptedPerform);
	}
}
