class NR_MagicBomb extends NR_MagicAction {
	var bombEntity : CMagicBombEntity;
	default actionType = ENR_BombExplosion;
	
	latent function onPrepare() : bool {
		super.onPrepare();

		resourceName = map[sign].getN("bomb_entity");
		entityTemplate = (CEntityTemplate)LoadResourceAsync( map[sign].getN("bomb_entity") );

		return onPrepared(true);
	}
	latent function onPerform() : bool {
		var targetNPC : CNewNPC;
		var super_ret : bool;
		super_ret = super.onPerform();
		if (!super_ret) {
			return onPerformed(false);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		bombEntity = (CMagicBombEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!bombEntity) {
			NRE("bombEntity is invalid.");
			return onPerformed(false);
		}
		bombEntity.DestroyAfter(bombEntity.settlingTime + 5.f);

		return onPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (bombEntity) {
			bombEntity.Destroy();
		}
	}
}
