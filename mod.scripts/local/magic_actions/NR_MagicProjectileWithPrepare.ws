class NR_MagicProjectileWithPrepare extends NR_MagicAction {
	var projectile 		: W3AdvancedProjectile;
	default actionType = ENR_ProjectileWithPrepare;

	latent function OnPrepare() : bool {
		var spearProjectile 	: W3IceSpearProjectile;
		var fireballProjectile 	: W3FireballProjectile;
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
			NRE("NR_MagicProjectileWithPrepare:: No valid projectile.");
			return OnPrepared(false);
		}
		spearProjectile = (W3IceSpearProjectile)projectile;
		fireballProjectile = (W3FireballProjectile)projectile;
		if (spearProjectile) {
			spearProjectile.initFxName = InitFxName();
			spearProjectile.onCollisionFxName = CollisionFxName();
			spearProjectile.onCollisionVictimFxName = m_fxNameHit;
			NRE("spearProjectile: initFxName = " + InitFxName() + ", CollisionFxName = " + CollisionFxName() + ", m_fxNameHit = " + m_fxNameHit);
		} else if (fireballProjectile) {
			fireballProjectile.initFxName = InitFxName();
			fireballProjectile.onCollisionFxName = CollisionFxName();
		} else {
			NRE("Unknown projectile type: " + projectile);
		}
		projectile.Init(thePlayer);
		projectile.CreateAttachment( thePlayer, 'r_weapon' );
		projectile.DestroyAfter(10.f);
		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ false, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}
		projectile.BreakAttachment();
		projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, pos, 20.f, standartCollisions );
		return OnPerformed(true);
	}

	latent function BreakAction() {
		var normal : Vector;

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
		var typeName : name = map[sign].getN("style_" + ENR_MAToName(actionType));
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
