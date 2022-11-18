class NR_MagicSpecialMeteor extends NR_MagicSpecialAction {
	var projectile 		: W3AdvancedProjectile;
	default actionType = ENR_SpecialMeteor;
	default actionName 	= 'AttackSpecialIgni';

	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 40);
		NRD("phraseChance = " + phraseChance);
		if ( phraseChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			phraseInputs.PushBack(18);
			phraseInputs.PushBack(19);
			phraseInputs.PushBack(20);
			phraseInputs.PushBack(21);
			PlayScene( phraseInputs );
		}

		return true;
	}
	latent function OnPrepare() : bool {
		super.OnPrepare();

		resourceName = map[sign].getN("meteor_entity", 'eredin_meteorite');
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
		projectile = (W3AdvancedProjectile)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!projectile) {
			NRE("NR_MagicSpecialMeteor:: No valid projectile.");
		}
		pos.Z -= 50.f;
		projectile.Init(NULL);
		projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, pos, 500.f, standartCollisions );

		return OnPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (projectile) {
			projectile.Destroy();
		}
	}
}
