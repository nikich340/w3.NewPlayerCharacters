class NR_MagicBomb extends NR_MagicAction {
	var l_bombEntity : CMagicBombEntity;
	var s_bombCount : int;
	var s_bombPursue : bool;

	default actionType = ENR_BombExplosion;
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

		resourceName = 'arcaneExplosion';
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

		// TODO! l_bombEntity.arcaneFxName = ArcaneFxName();
		// TODO! l_bombEntity.explosionFxName = ExplosionFxName();
		// TODO! if (target)
		// TODO! 	l_bombEntity.pursueTarget = target;
		// TODO! l_bombEntity.respectCaster = respectCaster;
		// l_bombEntity.Init();
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

	latent function ArcaneFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'arcane_circle_yellow';
			case ENR_ColorOrange:
				return 'arcane_circle_orange';
			case ENR_ColorRed:
				return 'arcane_circle_red';
			case ENR_ColorPink:
				return 'arcane_circle_pink';
			case ENR_ColorViolet:
				return 'arcane_circle_violet';
			case ENR_ColorBlue:
				return 'arcane_circle_blue';
			case ENR_ColorSeagreen:
				return 'arcane_circle_seagreen';
			case ENR_ColorGreen:
				return 'arcane_circle_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'arcane_circle_white';
		}
	}

	latent function ExplosionFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'explosion_yellow';
			case ENR_ColorOrange:
				return 'explosion_orange';
			case ENR_ColorRed:
				return 'explosion_red';
			case ENR_ColorPink:
				return 'explosion_pink';
			case ENR_ColorViolet:
				return 'explosion_violet';
			case ENR_ColorBlue:
				return 'explosion_blue';
			case ENR_ColorSeagreen:
				return 'explosion_seagreen';
			case ENR_ColorGreen:
				return 'explosion_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'explosion_white';
		}
	}
}
