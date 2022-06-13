class NR_MagicLightning extends NR_MagicAction {
	var dummyEffectName 	: name;
	default actionType = ENR_Lightning;
	default actionName 	= 'AttackLight';
	
	latent function onPrepare() : bool {
		super.onPrepare();

		entityTemplate = (CEntityTemplate)LoadResourceAsync("fx_dummy_entity");
		// lightning can destroy clues! if no attack target //
		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 0.f );
		dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		if (!dummyEntity) {
			NRE("DummyEntity is invalid.");
			return onPrepared(false);
		}
		((CGameplayEntity)dummyEntity).AddTag( 'nr_lightning_dummy_entity' );
		dummyEntity.DestroyAfter( 3.f );

		return onPrepared(true);
	}
	latent function onPerform() : bool {
		var targetNPC : CNewNPC;
		var component : CComponent;

		var super_ret : bool;
		super_ret = super.onPerform();
		if (!super_ret) {
			return onPerformed(false);
		}

		effectName = map[sign].getN("lightning_fx");
		effectHitName = map[sign].getN("throw_dummy_fx");
		if (target) {
			component = target.GetComponent('torso3effect');
			if (component) {
				thePlayer.PlayEffect(effectName, component);
			} else {
				thePlayer.PlayEffect(effectName, target);
			}

			targetNPC = (CNewNPC) target;
			if ( effectHitName != '' && (!targetNPC || !targetNPC.HasAlternateQuen()) ) {
				dummyEntity.PlayEffect(effectHitName);
			}
			thePlayer.OnCollisionFromItem(target);
		} else if (destroyable) {
			if (destroyable.reactsToIgni) {
				destroyable.OnIgniHit(NULL);
			} else {
				destroyable.OnAardHit(NULL);
			}
			thePlayer.PlayEffect(effectName, destroyable);
			dummyEntity.PlayEffect(effectHitName);
		} else {
			thePlayer.PlayEffect(effectName, dummyEntity);
			dummyEntity.PlayEffect(effectHitName);
		}

		return onPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.Destroy();
		}
	}
}
