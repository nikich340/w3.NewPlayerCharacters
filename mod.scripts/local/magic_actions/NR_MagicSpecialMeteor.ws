class NR_MagicSpecialMeteor extends NR_MagicSpecialAction {
	var s_respectCaster	: bool;
	var s_meteorNum 	: int;
	var meteor 			: NR_MeteorProjectile;
	
	default actionType = ENR_SpecialMeteor;
	default actionSubtype = ENR_SpecialAbstract;

	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 40);

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

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("DamageControl");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		resourceName = MeteorEntityName();
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName, true);

		s_respectCaster = IsActionAbilityUnlocked("DamageControl");
		s_meteorNum = SkillMaxApplies();

		return OnPrepared(true);
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
		var ret, super_ret 	: bool;
		var i 				: int;

		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false, scriptedPerform);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		
		ret = ShootMeteor();

		for (i = 0; i < s_meteorNum; i += 1) {
			ret = ShootMeteor();
			Sleep(0.05f);
		}

		StopAction();
		return OnPerformed(ret, scriptedPerform);
	}

	latent function ShootMeteor() : bool {
		var dk : float;
		var spawnPos : Vector;

		spawnPos = pos + VecRingRand(0.f, 1.f);

		if (IsInSetupScene()) {
			spawnPos = MidPosInScene(/*far*/ false);
		}
		spawnPos = SnapToGround(spawnPos);
		spawnPos.Z += 40.f;
		meteor = (NR_MeteorProjectile)theGame.CreateEntity(entityTemplate, spawnPos, rot);
		if (!meteor) {
			NRE("NR_MagicSpecialMeteor: No valid meteor. resourceName = " + resourceName + ", template: " + entityTemplate);
			return false;
		}
		/*meteor.initFxName = InitFxName();
		meteor.onCollisionFxName = ExplosionFxName();
		meteor.m_explosionFxName = ExplosionFxName();
		meteor.m_explosionWaterFxName = ExplosionWaterFxName();
		meteor.m_markerFxName = MarkerFxName();*/

		dk = 6.f - s_meteorNum;
		meteor.projDMG = GetDamage(/*min*/ 2.f*dk, /*max*/ 60.f*dk, /*vitality*/ 30.f, 8.f*dk, /*essence*/ 90.f, 10.f*dk /*randRange*/ /*customTarget*/);
		meteor.m_respectCaster = s_respectCaster;
		meteor.Init(thePlayer);
		//if (s_aim && target) {
		//	NRD("Meteor: ShootProjectileAtNode");
		//	meteor.ShootProjectileAtNode( meteor.projAngle, meteor.projSpeed, target, 500.f, standartCollisions );
		//} else {
		//	NRD("Meteor: ShootProjectileAtPosition");
		meteor.ShootProjectileAtPosition( meteor.projAngle, meteor.projSpeed, pos, 500.f, standartCollisions );
		//}
		meteor.DestroyAfter(10.f);

		return true;
	}

	latent function BreakAction() {
		if (isPerformed)
			return;
			
		super.BreakAction();
	}

	latent function MeteorEntityName() : String
	{
		var typeName 	: name = map[sign].getN("style_" + ENR_MAToName(actionType));
		var color 		: ENR_MagicColor = NR_GetActionColor();

		return "dlc/dlcnewreplacers/data/entities/magic/meteor/nr_" + NameToString(typeName) + "_meteor_" + ENR_MCToStringShort(color) + ".w2ent";
	}

	/*latent function InitFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			case ENR_ColorWhite:
				return 'smoke_white';
			case ENR_ColorYellow:
				return 'smoke_yellow';
			case ENR_ColorRed:
				return 'smoke_red';
			case ENR_ColorPink:
				return 'smoke_pink';
			case ENR_ColorViolet:
				return 'smoke_violet';
			case ENR_ColorBlue:
				return 'smoke_blue';
			case ENR_ColorSeagreen:
				return 'smoke_seagreen';
			case ENR_ColorGreen:
				return 'smoke_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorOrange:
			default:
				return 'smoke_orange';
		}
	}

	latent function ExplosionFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

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

	latent function ExplosionWaterFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

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

	latent function MarkerFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			case ENR_ColorWhite:
				return 'marker_white';
			case ENR_ColorYellow:
				return 'marker_yellow';
			case ENR_ColorRed:
				return 'marker_red';
			case ENR_ColorPink:
				return 'marker_pink';
			case ENR_ColorViolet:
				return 'marker_violet';
			case ENR_ColorBlue:
				return 'marker_blue';
			case ENR_ColorSeagreen:
				return 'marker_seagreen';
			case ENR_ColorGreen:
				return 'marker_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorOrange:
			default:
				return 'marker_orange';
		}
	}*/
}

state Cursed in NR_MagicSpecialMeteor {
	event OnEnterState( prevStateName : name )
	{
		NRD("Cursed: OnEnterState.");
		parent.inPostState = true;
		Curse();
	}

	entry function Curse() {
		Sleep(2.f);
		parent.target = thePlayer;
		parent.pos = thePlayer.GetWorldPosition();
		parent.s_respectCaster = false;

		parent.ShootMeteor();
		parent.StopAction();
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("Cursed: OnLeaveState.");
	}
}
