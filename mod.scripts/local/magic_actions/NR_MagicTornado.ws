class NR_MagicSpecialTornado extends NR_MagicAction {
	var tornadoEntity : NR_TornadoEntity;
	default actionType = ENR_SpecialTornado;
	
	latent function onPrepare() : bool {
		super.onPrepare();

		resourceName = map[sign].getN("tornado_entity");
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

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
		pos += VecRingRand(1.0f, 2.0f);
		tornadoEntity = (NR_TornadoEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!tornadoEntity) {
			NRE("tornadoEntity is invalid.");
			return onPerformed(false);
		}
		tornadoEntity.Init(thePlayer, target, pos, /*duration*/ 15.f);
		//tornadoEntity.DestroyAfter(tornadoEntity.m_duration + 5.f);

		return onPerformed(true);
	}
	latent function BreakAction() {
		if (isPerformed) // tornado is independent from caster
			return;

		super.BreakAction();
		if (tornadoEntity) {
			tornadoEntity.Destroy();
		}
	}
}
