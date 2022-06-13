class NR_MagicSpecialMeteor extends NR_MagicAction {
	var projectile 		: W3AdvancedProjectile;
	default actionType = ENR_SpecialMeteor;
	default actionName 	= 'AttackSpecialIgni';

	latent function onPrepare() : bool {
		super.onPrepare();

		resourceName = map[sign].getN("meteor_entity");
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);

		return onPrepared(true);
	}
	latent function onPerform() : bool {
		var super_ret : bool;
		super_ret = super.onPerform();
		if (!super_ret) {
			return onPerformed(false);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		pos += VecRingRand(0.f, 1.f);
		pos.Z += 50.f;
		projectile = (W3AdvancedProjectile)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!projectile) {
			NRE("NR_MagicSpecialMeteor:: No valid projectile.");
		}
		pos.Z -= 50.f;
		projectile.Init(NULL);
		projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, pos, 500.f, standartCollisions );

		return onPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (projectile) {
			projectile.Destroy();
		}
	}
}
