class NR_MagicSpecialSphere extends NR_MagicAction {
	default actionType = ENR_SpecialSphere;
	default actionName 	= 'AttackSpecialQuen';
	default drainStaminaOnPerform = false; // drained in NR_SorceressQuen

	latent function onPrepare() : bool {
		super.onPrepare();
		return onPrepared(true);
	}
	latent function onPerform() : bool {
		return onPerformed(true);
	}
}
