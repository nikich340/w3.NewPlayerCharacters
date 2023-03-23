class NR_MagicSpecialSphere extends NR_MagicAction {
	default actionType = ENR_SpecialSphere;
	default drainStaminaOnPerform = false; // drained in NR_SorceressQuen

	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 0);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			sceneInputs.PushBack(22);
			sceneInputs.PushBack(23);
			sceneInputs.PushBack(24);
			sceneInputs.PushBack(25);
			PlayScene( sceneInputs );
		}

		return true;
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();
		return OnPrepared(true);
	}
	
	latent function OnPerform() : bool {
		return OnPerformed(true);
	}
}
