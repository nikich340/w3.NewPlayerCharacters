statemachine class NR_MagicShip extends CGameplayEntity {
	var controlPoints : array<Vector>;
	var currentPointIndex : int;
	var currentRatio : float;
	var flySpeed : float;
	var collisionTemplate : CEntityTemplate;
	var collisionEntity : CEntity;
	default flySpeed = 1.f;
	default currentPointIndex = 0;
	default currentRatio = 0.f;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		collisionTemplate = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\nr_q210_large_nilfgaardian_ship_collision.w2ent", true);
		controlPoints.PushBack( Vector(-227.4654388428, -230.8441314697, 12.4462032318) );
		controlPoints.PushBack( Vector(-200.4654388428, -200.8441314697, 25.4462032318) );
		controlPoints.PushBack( Vector(-215.4654388428, -215.8441314697, 15.4462032318) );
		GotoState('Active');
	}
}

state Active in NR_MagicShip {
	event OnEnterState( prevStateName : name )
	{
		Fly();
	}


	latent function SetComponentsVisibilityByClassName( comps : array<CComponent>, visible : bool ) {
		var i : int;
		var drawableComp : CDrawableComponent;

		for (i = 0; i < comps.Size(); i += 1) {
			drawableComp = (CDrawableComponent)comps[i];
			if (drawableComp) {
				drawableComp.SetVisible(visible);
				drawableComp.SetCastingShadows(visible);
			}
		}
	}

	latent function SetVisibility( entity : CEntity, visible : bool )
	{
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CDrawableComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CBrushComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CDecalComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CDestructionSystemComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CGameplayDestructionSystemComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CDimmerComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CFlareComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CMergedMeshComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CMergedShadowMeshComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CMeshTypeComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CClothComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CDestructionComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CMeshComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CBgMeshComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CBgNpcItemComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CDressMeshComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CFurComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CImpostorMeshComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CStaticMeshComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CRigidMeshComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CBoatBodyComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CRigidMeshComponentCooked'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CScriptedDestroyableComponent'), visible );
		
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CWindowComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CParticleComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CParticleComponentCooked'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CStripeComponent'), visible );
		SetComponentsVisibilityByClassName( entity.GetComponentsByClassName('CSwarmRenderComponent'), visible );
	}

	entry function Fly() {
		var lastTime, currentTime, deltaTime : float;
		var remainVec, moveVec, currentPos, nextPoint : Vector;
		var currentRot : EulerAngles;
		var nextPointIndex : int;
		var newCollisionEntity : CEntity;

		lastTime = theGame.GetEngineTimeAsSeconds();
		nextPointIndex = GetNextPoint(parent.currentPointIndex);
		nextPoint = parent.controlPoints[nextPointIndex];
		currentPos = parent.GetWorldPosition();
		currentRot = parent.GetWorldRotation();
		remainVec = nextPoint - currentPos;

		while (true) {
			SleepOneFrame();
			currentTime = theGame.GetEngineTimeAsSeconds();
			deltaTime = currentTime - lastTime;
			if (deltaTime < 0.003f)
				continue;

			if (VecLengthSquared(remainVec) < 9.f) {
				nextPointIndex = GetNextPoint(parent.currentPointIndex);
				nextPoint = parent.controlPoints[nextPointIndex];
				NR_Debug("nextPoint(" + nextPointIndex + ") = " + VecToString(nextPoint));
				continue;
			}

			moveVec = VecNormalize(remainVec) * parent.flySpeed * deltaTime;
			currentPos += moveVec;
			parent.Teleport( currentPos );
			newCollisionEntity = theGame.CreateEntity( parent.collisionTemplate, currentPos, currentRot );
			//thePlayer.Teleport( thePlayer.GetWorldPosition() + moveVec );
			SetVisibility( newCollisionEntity, false );
			if (parent.collisionEntity) {
				parent.collisionEntity.Destroy();
			}
			parent.collisionEntity = newCollisionEntity;

			remainVec = nextPoint - currentPos;
			lastTime = currentTime;
			NR_Debug("Fly: deltaTime = " + deltaTime + ", moveVec = " + VecToString(moveVec));
		}
	}

	function GetNextPoint(point : int) : int {
		var ret : int;

		ret = point + 1;
		if (ret >= parent.controlPoints.Size())
			ret = 0;
		return ret;
	}
	
	event OnLeaveState( nextStateName : name )
	{

	}
}

state Idle in NR_MagicShip {

}
