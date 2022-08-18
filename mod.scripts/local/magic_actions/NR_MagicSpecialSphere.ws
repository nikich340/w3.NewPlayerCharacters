class NR_MagicSpecialSphere extends NR_MagicAction {
	default actionType = ENR_SpecialSphere;
	default actionName 	= 'AttackSpecialQuen';
	default drainStaminaOnPerform = false; // drained in NR_SorceressQuen

	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 40);
		NRD("phraseChance = " + phraseChance);
		if ( phraseChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			phraseInputs.PushBack(22);
			phraseInputs.PushBack(23);
			phraseInputs.PushBack(24);
			phraseInputs.PushBack(25);
			PlayScene( phraseInputs );
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
