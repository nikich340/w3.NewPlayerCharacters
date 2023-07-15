class NR_MagicCounterPush extends NR_MagicAction {
	var aardEntity		: W3AardEntity;
	var aardProjectile 	: NR_AardProjectile;
	var s_fullSphere, s_freeze, s_burn : bool;
	
	default actionType = ENR_CounterPush;
	default performsToLevelup = 150;

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("FullBlast");
		}
		if (newLevel == 8) {
			ActionAbilityUnlock("Freezing");
		}
		if (newLevel == 10) {
			ActionAbilityUnlock("Burning");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		pos = thePlayer.GetWorldPosition();
		rot = thePlayer.GetWorldRotation();

		entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_keira_metz_cast");
		aardEntity = (W3AardEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!aardEntity) {
			NRE("aardEntity is not valid.");
			return OnPrepared(false);
		}

		pos -= thePlayer.GetHeadingVector() * 0.7f;
		s_fullSphere = !isManual && IsActionAbilityUnlocked("FullBlast");
		if (!isManual && RandRange(100) + 1 <= 20 + SkillLevel()) {
			s_freeze = IsActionAbilityUnlocked("Freezing") && BuffType() == 1;
			if (!s_freeze) {
				s_burn = IsActionAbilityUnlocked("Burning") && BuffType() == 2;
			}
			
		}
		
		if (s_fullSphere) {
			pos.Z -= 0.5f;
			entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_aard_proj_blast");
		} else {
			pos.Z += 1.f;
			entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_aard_proj_cone");
		}
		
		aardProjectile = (NR_AardProjectile)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!aardProjectile) {
			NRE("aardProjectile is not valid.");
			return OnPrepared(false);
		}

		return OnPrepared(true);
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
		var attackRange : CAIAttackRange;
		var aardStandartCollisions : array<name>;
		var hitsWater : bool;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false, scriptedPerform);
		}
		
		aardStandartCollisions.PushBack( 'Projectile' );
		aardStandartCollisions.PushBack( 'Door' );
		aardStandartCollisions.PushBack( 'Static' );		
		aardStandartCollisions.PushBack( 'Character' );
		aardStandartCollisions.PushBack( 'Destructible' );
		aardStandartCollisions.PushBack( 'RigidBody' );
		aardStandartCollisions.PushBack( 'Corpse' );
		aardStandartCollisions.PushBack( 'ParticleCollider' );

		aardProjectile.useFullSphere = s_fullSphere;
		//aardProjectile.useSlowdown = s_slowdown;
		aardProjectile.useFreeze = s_freeze;
		aardProjectile.useBurn = s_burn;
		
		aardProjectile.ExtInit( NR_GetReplacerSorceress().nr_signOwner, S_Magic_1, aardEntity );
		if (s_fullSphere) {
			attackRange = theGame.GetAttackRangeForEntity( aardEntity, 'blast_upgrade2' );
			m_fxNameMain = BlastFxName();
			GCameraShake(0.4f, true, pos, 30.0f);
		} else {
			attackRange = theGame.GetAttackRangeForEntity( aardEntity, 'cone_upgrade2' );
			m_fxNameMain = ConeFxName();
			GCameraShake(0.2f, true, pos, 30.0f);
		}
		aardProjectile.SetAttackRange( attackRange );
		aardEntity.PlayEffect( m_fxNameMain );

		/*
		if (aardProjectile.useSlowdown) {
			NRD("AARD: Add ProcessSlowdown timer");
			aardProjectile.AddTimer('ProcessSlowdownTimer', 1.5f, false, , , true);
		}
		*/

		hitsWater = ((CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent()).GetSubmergeDepth() < 0;
		if (hitsWater)
			aardEntity.PlayEffect( 'blast_water' );
		else
			aardEntity.PlayEffect( 'blast_ground' );

		if (s_freeze) {
			//thePlayer.PlayEffect( 'mutation_6_power' );
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(pos, /*in*/ 0.3f, /*active*/ 5.f, /*out*/ 1.5f, attackRange.rangeMax, /*0 - frost, 1 - burn*/ 0 );
		} else if (s_burn) {
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(pos, /*in*/ 0.3f, /*active*/ 5.f, /*out*/ 1.5f, attackRange.rangeMax, /*0 - frost, 1 - burn*/ 1 );
		}

		if (s_fullSphere) {
			// aardProjectile.SphereOverlapTest( 12.f, aardStandartCollisions );
			aardProjectile.NR_ProcessCollisionNPCsInCone(/*range*/ 13.f, /*angle*/ 360.f, /*speed*/ 80.0f);
		} else {
			pos += thePlayer.GetHeadingVector() * 10.f;
			aardProjectile.ShootCakeProjectileAtPosition( /*angle*/ 120.f, /*height*/ 4.f, /*shootAngle*/ 0.0f, /*speed*/ 70.0f, /*target*/ pos, /*range*/ 10.f, aardStandartCollisions );
			aardProjectile.NR_ProcessCollisionNPCsInCone(/*range*/ 10.f, /*angle*/ 120.f, /*speed*/ 70.0f);
		}

		aardProjectile.DestroyAfter(10.f);
		aardEntity.DestroyAfter(10.f);

		return OnPerformed(true, scriptedPerform);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;
		super.BreakAction();
		if (aardProjectile) {
			aardProjectile.Destroy();
		}
		if (aardEntity) {
			aardEntity.Destroy();
		}
	}

	latent function BlastFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				return 'blast_yellow';
			case ENR_ColorOrange:
				return 'blast_orange';
			case ENR_ColorRed:
				return 'blast_red';
			case ENR_ColorPink:
				return 'blast_pink';
			case ENR_ColorViolet:
				return 'blast_violet';
			case ENR_ColorBlue:
				return 'blast_blue';
			case ENR_ColorSeagreen:
				return 'blast_seagreen';
			case ENR_ColorGreen:
				return 'blast_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'blast_white';
		}
	}

	latent function ConeFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				return 'cone_yellow';
			case ENR_ColorOrange:
				return 'cone_orange';
			case ENR_ColorRed:
				return 'cone_red';
			case ENR_ColorPink:
				return 'cone_pink';
			case ENR_ColorViolet:
				return 'cone_violet';
			case ENR_ColorBlue:
				return 'cone_blue';
			case ENR_ColorSeagreen:
				return 'cone_seagreen';
			case ENR_ColorGreen:
				return 'cone_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'cone_white';
		}
	}

	function BuffType() : int {
		// 0 = None, 1 = Freeze, 2 = Burn
		return map[sign].getI("buff_" + ENR_MAToName(actionType), 0);
	} 

	// unused
	latent function BlastMutationFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				return 'blast_ground_mutation_6_yellow';
			case ENR_ColorOrange:
				return 'blast_ground_mutation_6_orange';
			case ENR_ColorRed:
				return 'blast_ground_mutation_6_red';
			case ENR_ColorPink:
				return 'blast_ground_mutation_6_pink';
			case ENR_ColorViolet:
				return 'blast_ground_mutation_6_violet';
			case ENR_ColorBlue:
				return 'blast_ground_mutation_6_blue';
			case ENR_ColorSeagreen:
				return 'blast_ground_mutation_6_seagreen';
			case ENR_ColorGreen:
				return 'blast_ground_mutation_6_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'blast_ground_mutation_6';
		}
	}
}
