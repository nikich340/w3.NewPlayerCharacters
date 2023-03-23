class NR_MagicSpecialMeteor extends NR_MagicSpecialAction {
	var meteor 		: W3MeteorProjectile;
	default actionType = ENR_SpecialMeteor;

	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 0);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			sceneInputs.PushBack(18);
			sceneInputs.PushBack(19);
			sceneInputs.PushBack(20);
			sceneInputs.PushBack(21);
			PlayScene( sceneInputs );
		}

		return true;
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		resourceName = map[sign].getN("entity_" + ENR_MAToName(actionType));
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);

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
		pos += VecRingRand(0.f, 1.f);
		pos.Z += 50.f;
		meteor = (W3MeteorProjectile)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!meteor) {
			NRE("NR_MagicSpecialMeteor: No valid meteor.");
			meteor.Destroy();
			return OnPerformed(false);
		}
		pos.Z -= 50.f;
		meteor.markerEntityTemplate = (CEntityTemplate)LoadResourceAsync(MarkerDepotPath());
		// TOREMOVE? meteor.initFxName = InitFxName();
		meteor.onCollisionFxName = CollisionFxName();
		// TODO! meteor.onCollisionWaterFxName = CollisionWaterFxName();
		meteor.Init(NULL);
		meteor.ShootProjectileAtPosition( meteor.projAngle, meteor.projSpeed, pos, 500.f, standartCollisions );

		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;
			
		super.BreakAction();
		if (meteor) {
			meteor.Destroy();
		}
	}

	latent function MarkerDepotPath() : String {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_SpecialAbstract);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorWhite:
				return "dlc\dlcnewreplacers\data\entities\magic\special_meteor\marker_white.w2ent";
			case ENR_ColorYellow:
				return "dlc\dlcnewreplacers\data\entities\magic\special_meteor\marker_yellow.w2ent";
			case ENR_ColorRed:
				return "dlc\dlcnewreplacers\data\entities\magic\special_meteor\marker_red.w2ent";
			case ENR_ColorPink:
				return "dlc\dlcnewreplacers\data\entities\magic\special_meteor\marker_pink.w2ent";
			case ENR_ColorViolet:
				return "dlc\dlcnewreplacers\data\entities\magic\special_meteor\marker_violet.w2ent";
			case ENR_ColorBlue:
				return "dlc\dlcnewreplacers\data\entities\magic\special_meteor\marker_blue.w2ent";
			case ENR_ColorSeagreen:
				return "dlc\dlcnewreplacers\data\entities\magic\special_meteor\marker_seagreen.w2ent";
			case ENR_ColorGreen:
				return "dlc\dlcnewreplacers\data\entities\magic\special_meteor\marker_green.w2ent";
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorOrange:
			default:
				return "fx\quest\q403\meteorite\q403_marker.w2ent";
		}
	}

	latent function InitFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_SpecialAbstract);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorWhite:
			//	return 'smoke_white';
			//case ENR_ColorYellow:
			//	return 'smoke_orange';
			//case ENR_ColorOrange:
			//	return 'smoke_orange';
			//case ENR_ColorRed:
			//	return 'smoke_orange';
			//case ENR_ColorPink:
			//	return 'smoke_orange';
			//case ENR_ColorViolet:
			//	return 'smoke_orange';
			//case ENR_ColorBlue:
			//	return 'smoke_orange';
			//case ENR_ColorSeagreen:
			//	return 'smoke_orange';
			//case ENR_ColorGreen:
			//	return 'smoke_orange';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorGrey:
			default:
				return 'smoke';
		}
	}

	latent function CollisionFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_SpecialAbstract);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			case ENR_ColorWhite:
				return 'explosion_white';
			case ENR_ColorYellow:
				return 'explosion_yellow';
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
			case ENR_ColorOrange:
			default:
				return 'explosion_orange';
		}
	}

	latent function CollisionWaterFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_SpecialAbstract);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			case ENR_ColorWhite:
				return 'explosion_water_white';
			case ENR_ColorYellow:
				return 'explosion_water_yellow';
			case ENR_ColorRed:
				return 'explosion_water_red';
			case ENR_ColorPink:
				return 'explosion_water_pink';
			case ENR_ColorViolet:
				return 'explosion_water_violet';
			case ENR_ColorBlue:
				return 'explosion_water_blue';
			case ENR_ColorSeagreen:
				return 'explosion_water_seagreen';
			case ENR_ColorGreen:
				return 'explosion_water_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorOrange:
			default:
				return 'explosion_water_orange';
		}
	}
}
