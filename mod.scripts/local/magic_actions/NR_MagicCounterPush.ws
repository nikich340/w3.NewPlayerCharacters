class NR_MagicCounterPush extends NR_MagicAction {
	var aardEntity		: NR_SorceressAard;
	var aardProjectile 	: W3AardProjectile;
	default actionType = ENR_CounterPush;
	default actionName 	= 'AttackPush';

	latent function OnPrepare() : bool {
		super.OnPrepare();

		pos = thePlayer.GetWorldPosition();
		rot = thePlayer.GetWorldRotation();
		pos.Z -= 0.5;

		entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_aard");
		aardEntity = (NR_SorceressAard)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!aardEntity) {
			NRE("aardEntity is not valid.");
			return OnPrepared(false);
		}

		entityTemplate = (CEntityTemplate)LoadResourceAsync("gameplay\templates\signs\pc_aard_proj_blast.w2ent", true);
		aardProjectile = (W3AardProjectile)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!aardProjectile) {
			NRE("aardProjectile is not valid.");
			return OnPrepared(false);
		}

		return OnPrepared(true);
	}
	latent function OnPerform() : bool {
		var attackRange : CAIAttackRange;
		var aardstandartCollisions : array<name>;
		var hitsWater : bool;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}
		
		if ( !aardEntity.NR_Init(NR_GetReplacerSorceress().nr_signOwner) ) {
			NRD("Not enough stamina for action: " + actionType);
			return OnPerformed(false);
		}
		attackRange = theGame.GetAttackRangeForEntity( aardEntity, 'blast_upgrade3' );
		aardstandartCollisions.PushBack( 'Projectile' );
		aardstandartCollisions.PushBack( 'Door' );
		aardstandartCollisions.PushBack( 'Static' );		
		aardstandartCollisions.PushBack( 'Character' );
		aardstandartCollisions.PushBack( 'ParticleCollider' );

		aardProjectile.ExtInit( NR_GetReplacerSorceress().nr_signOwner, S_Magic_1, aardEntity );
		aardProjectile.SetAttackRange( attackRange );
		aardProjectile.SphereOverlapTest( 10.f, aardstandartCollisions );	
		GCameraShake(0.1f, true, pos, 30.0f); // 0.2 cone, 0.5 blast

		hitsWater = ((CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent()).GetSubmergeDepth() < 0;
		aardEntity.PlayEffect( 'blast_lv3' );
		aardEntity.PlayEffect( 'blast_lv3_damage' );
		aardEntity.PlayEffect( 'blast_lv3_power' );
		if(hitsWater)
			aardEntity.PlayEffect( 'blast_water' );
		else
			aardEntity.PlayEffect( 'blast_ground' );

		if (target && RandF() > 0.5) {
			target.AddEffectDefault( EET_SlowdownFrost, aardProjectile, "Mutation 6", true );
			aardEntity.PlayEffect( 'blast_ground_mutation_6' ); // freeze
			thePlayer.PlayEffect( 'mutation_6_power' );
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(pos, 0.3f, 3.f, 2.f, attackRange.rangeMax, /*0 - frost, 1 - burn*/ 0 );
			NR_Notify("FREEZE!");
		}
		aardProjectile.DestroyAfter(10.f);
		aardEntity.DestroyAfter(10.f);

		return OnPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (aardProjectile) {
			aardProjectile.Destroy();
		}
		if (aardEntity) {
			aardEntity.Destroy();
		}
	}
}
