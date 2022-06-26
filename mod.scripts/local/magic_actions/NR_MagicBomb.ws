class NR_MagicBomb extends NR_MagicAction {
	var l_bombEntity : CMagicBombEntity;
	var s_bombCount : int;
	var s_bombPursue : bool;

	default actionType = ENR_BombExplosion;
	default actionName = 'AttackHeavy';
	default s_bombCount 	= 1;
	default s_bombPursue 	= false;
	
	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 30);
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

		resourceName = map[sign].getN("bomb_entity");
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

		return OnPrepared(true);
	}
	latent function OnPerform() : bool {
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		l_bombEntity = (CMagicBombEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!l_bombEntity) {
			NRE("l_bombEntity is invalid.");
			return OnPerformed(false);
		}
		l_bombEntity.DestroyAfter(l_bombEntity.settlingTime + 5.f);

		return OnPerformed(true);
	}
	latent function BreakAction() {
		if (isPerformed) // bomb is independent from caster
			return;

		super.BreakAction();
		if (l_bombEntity) {
			l_bombEntity.Destroy();
		}
	}
}
