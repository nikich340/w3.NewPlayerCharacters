class NR_MagicProjectileWithPrepare extends NR_MagicAction {
	var projectile 		: W3AdvancedProjectile;
	default actionType = ENR_ProjectileWithPrepare;

	latent function onPrepare() : bool {
		super.onPrepare();

		resourceName = map[sign].getN("throw_entity");
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
			return onPrepared(false);
		}
		projectile.Init(thePlayer);
		projectile.CreateAttachment( thePlayer, 'r_weapon' );
		projectile.DestroyAfter(10.f);
		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ false, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );

		return onPrepared(true);
	}
	latent function onPerform() : bool {
		var super_ret : bool;
		super_ret = super.onPerform();
		if (!super_ret) {
			return onPerformed(false);
		}
		projectile.BreakAttachment();
		projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, pos, 20.f, standartCollisions );
		return onPerformed(true);
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
}
