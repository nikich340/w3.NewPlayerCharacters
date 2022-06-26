class NR_MagicLightning extends NR_MagicAction {
	var dummyEffectName 	: name;
	default actionType = ENR_Lightning;
	default actionName 	= 'AttackLight';

	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 20);
		NRD("phraseChance = " + phraseChance);
		if ( phraseChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			phraseInputs.PushBack(3);
			phraseInputs.PushBack(4);
			phraseInputs.PushBack(5);
			PlayScene( phraseInputs );
		}

		return true;
	}
	latent function OnPrepare() : bool {
		super.OnPrepare();

		entityTemplate = (CEntityTemplate)LoadResourceAsync("fx_dummy_entity");
		// lightning can destroy clues! if no attack target //
		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 0.f );
		dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		if (!dummyEntity) {
			NRE("DummyEntity is invalid.");
			return OnPrepared(false);
		}
		((CGameplayEntity)dummyEntity).AddTag( 'nr_lightning_dummy_entity' );
		dummyEntity.DestroyAfter( 3.f );

		return OnPrepared(true);
	}
	latent function OnPerform() : bool {
		var targetNPC : CNewNPC;
		var component : CComponent;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
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

		return OnPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.Destroy();
		}
	}
}
