class NR_MagicSpecialSphere extends NR_MagicAction {
	default actionType = ENR_SpecialSphere;
	latent function onPrepare() : bool {
		super.onPrepare();
		return onPrepared(true);
	}
	latent function onPerform() : bool {
		return onPerformed(true);
	}
}
