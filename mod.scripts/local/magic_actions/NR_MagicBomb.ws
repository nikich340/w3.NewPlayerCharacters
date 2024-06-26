class NR_MagicBomb extends NR_MagicAction {
	var l_bombEntity : NR_MagicBombEntity;

	default actionType = ENR_BombExplosion;
	default actionSubtype = ENR_HeavyAbstract;
	
	latent function OnInit() : bool {
		sceneInputs.PushBack(3);
		sceneInputs.PushBack(4);
		sceneInputs.PushBack(5);
		super.OnInit();

		return true;
	}

	latent function OnPrepare() : bool {
		var depotPath : String;

		super.OnPrepare();

		depotPath = BombDepotPath();
		entityTemplate = (CEntityTemplate)LoadResourceAsync( depotPath, true );
		if (!entityTemplate) {
			NR_Error(actionType + ".OnPrepare: !entityTemplate, " + depotPath);
			return OnPrepared(false);
		}

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var super_ret : bool;
		var bombPursue : bool;
		var respectCaster : bool;
		var dk : float;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		l_bombEntity = (NR_MagicBombEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!l_bombEntity) {
			NR_Error("l_bombEntity is invalid, template = " + entityTemplate);
			return OnPerformed(false);
		}
		bombPursue = IsActionAbilityEnabled("Pursuit");
		respectCaster = IsActionAbilityEnabled("DamageControl");

		l_bombEntity.m_fxName = ArcaneFxName();
		l_bombEntity.m_explosionFxName = ExplosionFxName();
		l_bombEntity.m_metersPerSec = 1.f;
		dk = 2.f * SkillTotalDamageMultiplier();
		l_bombEntity.m_damageVal = NR_GetDamageGeneric("NR_MagicBomb", thePlayer, target, /*min*/ 1.5f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/);
		l_bombEntity.Init(thePlayer, target, /*respectCaster*/ respectCaster, /*pursue*/ bombPursue);
		l_bombEntity.DestroyAfter(l_bombEntity.m_timeToExplode + 5.f);

		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		if (l_bombEntity) {
			l_bombEntity.Destroy();
		}
	}

	latent function BombDepotPath() : String {
		var style : name = map[sign].getN("style_" + ENR_MAToName(ENR_BombExplosion), 'tower_nowhere');
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (style) {
			case 'tower_nowhere':
				return "dlc\dlcnewreplacers\data\entities\magic\bomb\nr_sq210_lightning_" + ENR_MCToStringShort(color) + ".w2ent";
			default:
				return "dlc\dlcnewreplacers\data\entities\magic\bomb\nr_" + NameToString(style) + "_bomb.w2ent";
		}
	}

	latent function ArcaneFxName() : name {
		var style : name = map[sign].getN("style_" + ENR_MAToName(ENR_BombExplosion), 'tower_nowhere');
		var color : ENR_MagicColor = NR_GetActionColor();

		if (style == 'tower_nowhere')
			return 'pre_lightning';

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
		var style : name = map[sign].getN("style_" + ENR_MAToName(ENR_BombExplosion), 'tower_nowhere');
		var color : ENR_MagicColor = NR_GetActionColor();

		if (style == 'tower_nowhere')
			return 'lightning';

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
