statemachine class NR_MagicRock extends NR_MagicAction {
	var projectile 		: W3AdvancedProjectile;
	var lProjectiles 	: array<W3AdvancedProjectile>;

	var lStartPositions : array<Vector>;
	var lFinalPositions : array<Vector>;
	var lStartTime 		: float;
	var lPrevTime 		: float;
	var lLoopActive		: bool;

	default actionType = ENR_Rock;
	default actionName 	= 'AttackHeavy';
	
	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 30);
		NRD("phraseChance = " + phraseChance);
		if ( phraseChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			phraseInputs.PushBack(3);
			phraseInputs.PushBack(4);
			phraseInputs.PushBack(5);
			PlayScene( phraseInputs );
		}

		return true;
	}
	latent function OnPrepare() : bool {
		var i, numberOfCircles, numberToSpawn, numPerCircle : int;
		var startTime				: float;
		var raiseObjectsHeightNoise, spawnObjectsInConeAngle, coneAngle, coneWidth, spawnRadiusMin, spawnRadiusMax, circleRadiusMin, circleRadiusMax : float;
		var spawnPos, spawnCenter, normalCollision 	: Vector;
		var spawnRot 				: EulerAngles;

		super.OnPrepare();

		//parent.HandFX(false);
		resourceName = map[sign].getN("rock_proj");
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
		// BTTaskPullObjectsFromGroundAndShoot, Keira Metz & Djinni //
		numberToSpawn			= 9;
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
			spawnPos = spawnCenter + VecConeRand( thePlayer.GetHeading() - ( spawnObjectsInConeAngle * 0.5f ) + ( coneAngle * i ), coneWidth, circleRadiusMin, circleRadiusMax );
			theGame.GetWorld().StaticTrace( spawnPos + Vector(0,0,5), spawnPos - Vector(0,0,5), spawnPos, normalCollision );
			spawnRot = VecToRotation( thePlayer.GetWorldPosition() - spawnPos);
			
			projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, spawnPos + Vector(0,0,0.3f), spawnRot );
			projectile.PlayEffect('glow');
			lStartPositions.PushBack( spawnPos );
			lProjectiles.PushBack(projectile);

			raiseObjectsHeightNoise = 0.5f;
			spawnPos.Z += ((CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent()).GetCapsuleHeight() * RandRangeF( 1.f + raiseObjectsHeightNoise, 1.f - raiseObjectsHeightNoise );
			lFinalPositions.PushBack( spawnPos );
		}
		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ false, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );

		lLoopActive = true;
		lStartTime = EngineTimeToFloat(theGame.GetEngineTime());
		lPrevTime = EngineTimeToFloat(theGame.GetEngineTime());

		inPostState = true;
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

		PopState( true );
		// aard effect
		resourceName = map[sign].getN("rock_push_entity");
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		spawnPos = thePlayer.GetWorldPosition() + Vector(0, 0, 1.15);
		spawnRot = thePlayer.GetWorldRotation();
		dummyEntity = theGame.CreateEntity( entityTemplate, spawnPos, spawnRot );

		dummyEntity.CreateAttachment( thePlayer );
		dummyEntity.PlayEffect( 'cone' ); // 'blast' 'cone'
		dummyEntity.DestroyAfter(5.f);

		NRD("rock: OnPerform, lProjectiles = " + lProjectiles.Size() + ", state = " + GetCurrentStateName());
		for ( i = lProjectiles.Size() - 1 ; i >= 0 ; i -= 1 ) 
		{
			projectile = lProjectiles.PopBack();
			lStartPositions.PopBack();
			lFinalPositions.PopBack();
			projectile.Init( thePlayer );
			projectile.StopEffect( 'glow' );

			distToTarget = VecDistance2D( pos, thePlayer.GetWorldPosition() );
			// a bit randomness
			pos = pos + Vector(RandRangeF(randNoise, -randNoise), RandRangeF(randNoise, -randNoise), RandRangeF(randNoise, -randNoise));
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
			projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, pos, range, standartCollisions );
			projectile.DestroyAfter(10.f);
		}
		inPostState = false;
		return OnPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		GotoState('Break');
	}
}

state Loop in NR_MagicRock {
	event OnEnterState( prevStateName : name )
	{		
		parent.lLoopActive = true;
		LoopMove();
	}
	event OnLeaveState( nextStateName : name )
	{		
		parent.lLoopActive = false;
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

		while (true) {
			SleepOneFrame();
			currentTime = EngineTimeToFloat(theGame.GetEngineTime());
			if (currentTime - parent.lStartTime > 1.5f) {
				NRE("LoopMove: Perform should have been received? Delay = " + (currentTime - parent.lStartTime));
				//parent.GotoState('Break');
				//return;
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
		BreakMove();
	}
	event OnLeaveState( nextStateName : name )
	{
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
			projectile.StopEffect( 'glow' );
			
			// dropping
			range = RandRangeF( 1, 0 );
			spawnPos = projectile.GetWorldPosition() + projectile.GetHeadingVector() * range;
			projectile.ShootProjectileAtPosition( projectile.projAngle, 5, spawnPos, range, parent.standartCollisions );
			projectile.DestroyAfter(10.f);
		}
		parent.inPostState = false;
	}
}
