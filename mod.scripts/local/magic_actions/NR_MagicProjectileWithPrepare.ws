class NR_MagicProjectileWithPrepare extends NR_MagicAction {
	var projectile 		: W3AdvancedProjectile;
	
	default actionType = ENR_ProjectileWithPrepare;
	default actionSubtype = ENR_ThrowAbstract;

	latent function OnInit() : bool {
		sceneInputs.PushBack(3);
		sceneInputs.PushBack(4);
		sceneInputs.PushBack(5);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("AutoAim");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		var spearProjectile 	: W3IceSpearProjectile;
		var fireballProjectile 	: W3FireballProjectile;
		var dk 		: float;
		super.OnPrepare();

		resourceName = ProjectileEntityName();
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
		rot = thePlayer.GetWorldRotation();
		pos = thePlayer.GetWorldPosition();

		// special case for frost line proj
		//if (actionType == ENR_Projectile)
		//	projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, pos + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f, rot );
		pos.Z += 1.f;
		projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, pos, rot );
		if (!projectile) {
			NR_Error("NR_MagicProjectileWithPrepare:: No valid projectile.");
			return OnPrepared(false);
		}
		spearProjectile = (W3IceSpearProjectile)projectile;
		fireballProjectile = (W3FireballProjectile)projectile;
		if (spearProjectile) {
			spearProjectile.initFxName = InitFxName();
			spearProjectile.onCollisionFxName = CollisionFxName();
			spearProjectile.onCollisionVictimFxName = m_fxNameHit;
			NR_Debug("spearProjectile: initFxName = " + InitFxName() + ", CollisionFxName = " + CollisionFxName() + ", m_fxNameHit = " + m_fxNameHit);
		} else if (fireballProjectile) {
			fireballProjectile.initFxName = InitFxName();
			fireballProjectile.onCollisionFxName = CollisionFxName();
			NR_Debug("fireballProjectile: initFxName = " + InitFxName() + ", CollisionFxName = " + CollisionFxName());
		} else {
			NR_Error("Unknown projectile type: " + projectile);
		}
		dk = 1.5f * SkillTotalDamageMultiplier();
		projectile.projDMG = GetDamage(/*min*/ 1.f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/ /*customTarget*/);
		projectile.Init(thePlayer);
		projectile.CreateAttachment( thePlayer, 'r_weapon' );
		// explodes toxic gas
		projectile.AddTag(theGame.params.TAG_OPEN_FIRE);
		projectile.DestroyAfter(10.f);
		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ false, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var super_ret : bool;
		var component : CComponent;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}
		projectile.BreakAttachment();
		if (target && IsActionAbilityUnlocked("AutoAim")) {
			component = target.GetComponent('torso3effect');
			if (component)
				projectile.ShootProjectileAtNode( projectile.projAngle, projectile.projSpeed, component, 25.f, standartCollisions );
			else
				projectile.ShootProjectileAtNode( projectile.projAngle, projectile.projSpeed, target, 25.f, standartCollisions );
		} else {
			projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, pos, 25.f, standartCollisions );
		}
		return OnPerformed(true);
	}

	latent function BreakAction() {
		var normal : Vector;
		if (isPerformed)
			return;

		super.BreakAction();
		if (projectile) {
			pos = projectile.GetWorldPosition();
			theGame.GetWorld().StaticTrace(pos, pos - Vector(0,0,5), pos, normal);
			projectile.BreakAttachment();
			projectile.ShootProjectileAtPosition( projectile.projAngle, 5.f, pos, 20.f, standartCollisions );
			projectile.DestroyAfter(5.f);
		}
	}

	latent function ProjectileEntityName() : String
	{
		var typeName : name;
		if (isOnHorse)
			typeName = map[sign].getN("style_horse_" + ENR_MAToName(actionType));
		else
			typeName = map[sign].getN("style_" + ENR_MAToName(actionType));
		
		switch (typeName) {
			case 'philippa':
				return "nr_philippa_missile";
			case 'caranthir':
				return "nr_caranthir_icespear";
			case 'triss':
			default:
				return "nr_triss_fireball";
		}
	}

	latent function InitFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_ThrowAbstract);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'fire_fx_yellow';
			case ENR_ColorOrange:
				return 'fire_fx_orange';
			case ENR_ColorRed:
				return 'fire_fx_red';
			case ENR_ColorPink:
				return 'fire_fx_pink';
			case ENR_ColorViolet:
				return 'fire_fx_violet';
			case ENR_ColorBlue:
				return 'fire_fx_blue';
			case ENR_ColorSeagreen:
				return 'fire_fx_seagreen';
			case ENR_ColorGreen:
				return 'fire_fx_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'fire_fx_white';
		}
	}
	
	latent function CollisionFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_ThrowAbstract);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
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
