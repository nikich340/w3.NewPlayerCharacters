statemachine class NR_MagicRock extends NR_MagicAction {
	var projectile 		: W3AdvancedProjectile;
	var lProjectiles 	: array<W3AdvancedProjectile>;
	var lStartPositions : array<Vector>;
	var lFinalPositions : array<Vector>;
	var lStartTime 		: float;
	var lPrevTime 		: float;
	var lLoopActive		: bool;

	default actionType = ENR_Rock;
	default actionSubtype = ENR_HeavyAbstract;
	
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
		var i, numberOfCircles, numberToSpawn, numPerCircle : int;
		var startTime				: float;
		var raiseObjectsHeightNoise, spawnObjectsInConeAngle, coneAngle, coneWidth, spawnRadiusMin, spawnRadiusMax, circleRadiusMin, circleRadiusMax : float;
		var spawnPos, spawnCenter, normalCollision 	: Vector;
		var spawnRot 				: EulerAngles;
		var dk : float;

		super.OnPrepare();

		m_fxNameMain = GlowFxName();
		m_fxNameExtra = PushFxName();

		//parent.HandFX(false);
		resourceName = RockEntityName();
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
		// BTTaskPullObjectsFromGroundAndShoot, Keira Metz & Djinni //
		numberToSpawn			= 10;
		dk 						= 2.5f * SkillTotalDamageMultiplier() / numberToSpawn;
		numberToSpawn 			+= SkillLevel();

		numberOfCircles 		= 1; // don't change this
		spawnObjectsInConeAngle = 45.f;
		numPerCircle 			= FloorF( (float) numberToSpawn / (float) numberOfCircles );
		coneAngle 				= spawnObjectsInConeAngle / (float) numPerCircle;
		coneWidth 				= coneAngle;
		spawnRadiusMin			= 2;
		spawnRadiusMax			= 3;

		spawnCenter 			= thePlayer.GetWorldPosition();

		for	(i = 0; i < numberToSpawn; i += 1) {
			circleRadiusMin = spawnRadiusMin + ( 1.f / (float) numberOfCircles ) * ( spawnRadiusMax - spawnRadiusMin) ;
			circleRadiusMax = spawnRadiusMax - ( 1.f / (float) numberOfCircles ) * ( spawnRadiusMax - spawnRadiusMin) ;
			if (!IsInSetupScene())
				spawnPos = spawnCenter + VecConeRand( thePlayer.GetHeading() - ( spawnObjectsInConeAngle * 0.5f ) + ( coneAngle * i ), coneWidth, circleRadiusMin, circleRadiusMax );
			else
				spawnPos = spawnCenter + thePlayer.GetHeadingVector() + VecRingRand(0, 0.5);
			theGame.GetWorld().StaticTrace( spawnPos + Vector(0,0,5), spawnPos - Vector(0,0,5), spawnPos, normalCollision );
			spawnRot = VecToRotation( thePlayer.GetWorldPosition() - spawnPos);
			
			projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, spawnPos + Vector(0,0,0.3f), spawnRot );
			projectile.projDMG = GetDamage(/*min*/ 1.f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/ /*customTarget*/);
			projectile.PlayEffect( m_fxNameMain );
			lStartPositions.PushBack( spawnPos );
			lProjectiles.PushBack(projectile);

			raiseObjectsHeightNoise = 0.5f;
			spawnPos.Z += ((CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent()).GetCapsuleHeight() * NR_GetRandomGenerator().nextRangeF( 1.f - raiseObjectsHeightNoise, 1.f + raiseObjectsHeightNoise );
			lFinalPositions.PushBack( spawnPos );
		}
		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ false, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );

		lLoopActive = true;
		lStartTime = EngineTimeToFloat(theGame.GetEngineTime());
		lPrevTime = EngineTimeToFloat(theGame.GetEngineTime());

		this.GotoState('Loop');
		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var i 					: int;
		var shootDirectionNoise : float = 2.5f;
		var drawSpeedLimit 		: float = 10.f;
		var randNoise 			: float = 0.5f;
		var range, distToTarget, distance3DToTarget, projectileFlightTime, npcToTargetAngle	: float;
		var spawnPos			: Vector;
		var spawnRot			: EulerAngles;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		// stop rotating
		PopState( true );
		// "aard" push effect
		resourceName = 'nr_lynx_aard'; // lynx_cast ?
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		spawnPos = thePlayer.GetWorldPosition() + Vector(0, 0, 1.15);
		spawnRot = thePlayer.GetWorldRotation();
		dummyEntity = theGame.CreateEntity( entityTemplate, spawnPos, spawnRot );
		//if (!dummyEntity) {
		//	NRE("Invalid dummyEntity (" + dummyEntity + "), entityTemplate (" + entityTemplate + ")");
		//}

		dummyEntity.CreateAttachment( thePlayer );
		dummyEntity.PlayEffect( m_fxNameExtra ); // 'blast' 'cone'
		dummyEntity.DestroyAfter(5.f);

		NRD("rock: OnPerform, lProjectiles = " + lProjectiles.Size() + ", state = " + GetCurrentStateName());
		// shoot projectiles
		for ( i = lProjectiles.Size() - 1 ; i >= 0 ; i -= 1 ) 
		{
			projectile = lProjectiles.PopBack();
			lStartPositions.PopBack();
			lFinalPositions.PopBack();
			projectile.Init( thePlayer );
			projectile.StopEffect( m_fxNameMain );

			distToTarget = VecDistance2D( pos, thePlayer.GetWorldPosition() );
			// a bit randomness
			pos = pos + Vector(NR_GetRandomGenerator().nextRangeF(-randNoise, randNoise), NR_GetRandomGenerator().nextRangeF(-randNoise, randNoise), NR_GetRandomGenerator().nextRangeF(-randNoise, randNoise));
			// shooting
			range = 100.f;
			if (target) {
				npcToTargetAngle = NodeToNodeAngleDistance( target, thePlayer );
				//pos = projectile.GetWorldPosition() + VecFromHeading( AngleNormalize180( thePlayer.GetHeading() - npcToTargetAngle + RandRangeF( shootDirectionNoise, -shootDirectionNoise ) ) ) * distToTarget;
				// gameplay event
				distance3DToTarget = VecDistance( thePlayer.GetWorldPosition(), pos );		
				projectileFlightTime = distance3DToTarget / drawSpeedLimit;
				target.SignalGameplayEventParamFloat( 'Time2DodgeProjectile', projectileFlightTime );
			}
			if (target && IsActionAbilityUnlocked("AutoAim")) {
				projectile.ShootProjectileAtNode( projectile.projAngle, projectile.projSpeed, target, range, standartCollisions );
			} else {
				projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, pos, range, standartCollisions );
			}
			projectile.DestroyAfter(10.f);
		}
		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;
			
		super.BreakAction();
		GotoState('Break');
	}

	latent function RockEntityName() : String
	{
		var typeName : name = map[sign].getN("style_" + ENR_MAToName(actionType));
		switch (typeName) {
			case 'djinn':
				return "nr_djinn_wood_proj";
			case 'keira':
			default:
				return "nr_lynx_stone_proj";
		}
	}

	latent function GlowFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'glow_yellow';
			case ENR_ColorOrange:
				return 'glow_orange';
			case ENR_ColorRed:
				return 'glow_red';
			case ENR_ColorPink:
				return 'glow_pink';
			case ENR_ColorViolet:
				return 'glow_violet';
			case ENR_ColorBlue:
				return 'glow_blue';
			case ENR_ColorSeagreen:
				return 'glow_seagreen';
			case ENR_ColorGreen:
				return 'glow_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'glow_white';
		}
	}

	latent function PushFxName() : name {
		var color : ENR_MagicColor = NR_FinalizeColor( map[sign].getI("color_cone_" + ENR_MAToName(actionType), ENR_ColorWhite) );

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
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
}

state Loop in NR_MagicRock {
	event OnEnterState( prevStateName : name )
	{		
		parent.lLoopActive = true;
		parent.inPostState = true;
		LoopMove();
	}

	event OnLeaveState( nextStateName : name )
	{		
		parent.lLoopActive = false;
		parent.inPostState = false;
	}	

	entry function LoopMove()
	{	
		var speed, prevSpeed, deltaTime		: float;
		var speedModifier					: float;
		var drawSpeedLimit					: float = 10.f;
		var drawEntityRotationSpeed			: float = 4.f;
		var entityToFinalPosDist			: float;
		var initialToFinalPosDist			: float;
		var calculateSpeedFromPullDuration	: float = 1.2f;
		var desiredAffectedEntityPos 		: Vector;
		var rotationSpeedNoise				: float;
		var CreatedEntities					: array<CEntity>;
		var i 								: int;
		var currentTime 					: float;
		var spawnPos 						: Vector;
		var spawnRot 						: EulerAngles;

		while (!parent.isBroken && !parent.isPerformed) {
			SleepOneFrame();
			currentTime = EngineTimeToFloat(theGame.GetEngineTime());
			if (currentTime - parent.lStartTime > 1.5f) {
				NRE("LoopMove: Perform should have been received? Delay = " + (currentTime - parent.lStartTime));
				parent.GotoState('Break');
				return;
			}

			deltaTime = EngineTimeToFloat(theGame.GetEngineTime()) - parent.lPrevTime;
			parent.lPrevTime = EngineTimeToFloat(theGame.GetEngineTime());
			for ( i = parent.lProjectiles.Size() - 1 ; i >= 0 ; i -= 1 )
			{
				spawnPos = parent.lProjectiles[i].GetWorldPosition();
				entityToFinalPosDist = VecDistance( spawnPos, parent.lFinalPositions[i] );
				
				rotationSpeedNoise = RandRangeF( 1, -1 );
				spawnRot = parent.lProjectiles[i].GetWorldRotation();
				spawnRot.Pitch += drawEntityRotationSpeed + rotationSpeedNoise;
				spawnRot.Yaw += drawEntityRotationSpeed + rotationSpeedNoise;

				initialToFinalPosDist = VecDistance( parent.lFinalPositions[i], parent.lStartPositions[i] );
				speedModifier = initialToFinalPosDist / calculateSpeedFromPullDuration;
				prevSpeed = speedModifier;
				speed = prevSpeed - ( speedModifier * deltaTime );
				speed = MinF(drawSpeedLimit, MaxF(speed, 0.f));
				
				prevSpeed = speed;
				
				desiredAffectedEntityPos = spawnPos + VecNormalize( parent.lFinalPositions[i] - spawnPos  ) * speed * deltaTime;
				
				if ( VecDistance( spawnPos, desiredAffectedEntityPos ) < entityToFinalPosDist )
				{
					parent.lProjectiles[i].TeleportWithRotation( desiredAffectedEntityPos, spawnRot );
				}
				else
				{
					parent.lProjectiles[i].TeleportWithRotation( spawnPos, spawnRot );
				}
			}
		}
	}
}

state Break in NR_MagicRock {
	event OnEnterState( prevStateName : name )
	{		
		parent.isPrepared = true;
		parent.isPerformed = true;
		parent.lLoopActive = false;
		parent.inPostState = true;
		BreakMove();
	}

	event OnLeaveState( nextStateName : name )
	{
		parent.inPostState = false;
	}

	entry function BreakMove() {
		var range		: float;
		var i			: int;
		var projectile	: W3AdvancedProjectile;
		var spawnPos 	: Vector;

		for ( i = parent.lProjectiles.Size() - 1 ; i >= 0 ; i -= 1 ) 
		{
			projectile = parent.lProjectiles.PopBack();
			parent.lStartPositions.PopBack();
			parent.lFinalPositions.PopBack();
			projectile.Init( thePlayer );
			projectile.StopEffect( parent.m_fxNameMain );
			
			// dropping
			range = NR_GetRandomGenerator().nextRangeF( 0, 1 );
			spawnPos = projectile.GetWorldPosition() + projectile.GetHeadingVector() * range;
			projectile.ShootProjectileAtPosition( projectile.projAngle, 5, spawnPos, range, parent.standartCollisions );
			projectile.DestroyAfter(10.f);
		}
		parent.inPostState = false;
	}
}
