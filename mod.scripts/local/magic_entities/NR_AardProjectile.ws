class NR_AardProjectile extends W3AardProjectile {
	var targetEntities 		: array<CGameplayEntity>;
	var useSlowdown			: bool;
	var useFreeze 			: bool;
	var useBurn 			: bool;
	var useFullSphere 		: bool;
	/*event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		NR_Debug("OnProjectileCollision: collidingComponent = " + collidingComponent);
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}*/

	protected function ProcessCollisionOnEntity( target : CGameplayEntity ) {
		var params 	: SCustomEffectParams;
		var npc  	: CNewNPC;

		if (targetEntities.FindFirst(target) > -1)
			return;

		targetEntities.PushBack(target);
		target.OnAardHit( this );

		npc = (CNewNPC)target;
		if (!npc)
			return;

		params.creator = thePlayer;
		params.sourceName = 'NR_AardProjectile';
		//params.effectValue.valueAdditive = 50.f + 20.f * target.GetLevel();

		if (useFreeze) {
			params.duration = 5.f;
			params.effectType = EET_Frozen;
		} else if (useBurn) {
			params.duration = 5.f;
			params.effectType = EET_Burning;
		} else {
			params.duration = 5.f;
			/*
			if (!target.IsImmuneToBuff(EET_HeavyKnockdown))
				params.effectType = EET_HeavyKnockdown;
			else if (!target.IsImmuneToBuff(EET_LongStagger))
				params.effectType = EET_LongStagger;
			else
				params.effectType = EET_KnockdownTypeApplicator;
			*/
			params.effectValue.valueBase = 100.f;
			params.effectValue.valueMultiplicative = 100.f;
			params.effectValue.valueAdditive = 100.f;
			params.effectType = EET_KnockdownTypeApplicator;
		}
		npc.AddEffectCustom(params);
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var target : CNewNPC;

		NR_Debug("AARD: ProcessCollision: collider = " + collider);
		target = (CNewNPC)collider;
		if (target && target.IsAlive()) {
			if (useFullSphere) {
				ProcessCollisionOnEntity(target);
			}
			// CONE: do nothing - target is processed by ProcessCollisionNPCsInCone
		} else {
			super.ProcessCollision(collider, pos, normal);
		}

		NR_Debug("AARD: ProcessCollision: target = " + target);
		//action.AddEffectInfo( EET_HeavyKnockdown );
		//super.ProcessCollision(collider, pos, normal);
	}

	/*
	public timer function ProcessSlowdownTimer( delta : float, id : int ) {
		var i : int;
		var params : SCustomEffectParams;

		params.creator = thePlayer;
		params.duration = 7.f;
		params.sourceName = 'NR_AardProjectile';
		params.effectType = EET_SlowdownAxii; // 0.7
		// victimNPC.AddEffectDefault( EET_SlowdownFrost, this, "Mutation 6", true );
		params.customFXName = 'axii_slowdown';

		NR_Debug("AARD: ProcessSlowdown: entities: " + targetEntities.Size());
		for (i = 0; i < targetEntities.Size(); i += 1) {
			targetEntities[i].AddEffectCustom(params);
			NR_Debug("AARD: ProcessSlowdown: " + targetEntities[i]);
		}
	}
	*/

	latent function NR_ProcessCollisionNPCsInCone(range : float, angle : float, metersPerSec : float) {
		var actors 	: array <CActor>;
		var nodes 	: array <CNode>;
		var npc 	: CNewNPC;
		var pos, npcPos : Vector;
		var i 		: int;
		var timePassed, timeWait : float;

		pos = this.GetWorldPosition();
		if (angle > 359.f) {
			actors = thePlayer.GetNPCsAndPlayersInRange(/*range*/ range, , , /*flags*/ FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile);
		} else {
			actors = thePlayer.GetNPCsAndPlayersInCone(/*range*/ range, /*coneDir*/ thePlayer.GetHeading(), /*coneAngle*/ angle, , , /*flags*/ FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile);
		}
		
		NR_Debug("AARD: " + actors.Size() + " targets");
		for (i = 0; i < actors.Size(); i += 1) {
			nodes.PushBack(actors[i]);
			NR_Debug("actors[" + i + "] = " + actors[i]);
		}
		SortNodesByDistance(pos, nodes);

		timePassed = 0.f;
		for (i = 0; i < nodes.Size(); i += 1) {
			npc = (CNewNPC)nodes[i];
			npcPos = npc.GetWorldPosition();
			if (!npc || !npc.IsAlive() || AbsF(pos.Z - npcPos.Z) > 2.f)
				continue;
			
			timeWait = VecDistance2D(pos, npcPos) / metersPerSec;
			NR_Debug("npc[" + i + "] = " + npc + ", timeWait = " + timeWait);
			timeWait -= timePassed;
			if (timeWait > 0.01f) {
				Sleep(timeWait);
				timePassed += timeWait;
			}
			ProcessCollisionOnEntity(npc);
		}
	}

	latent function NR_ProcessCollisionEntitiesInCone(range : float, angle : float, metersPerSec : float) {
		var entities : array <CGameplayEntity>;
		var nodes 	: array <CNode>;
		var entity 	: CGameplayEntity;
		var actor 	: CActor;
		var pos, entityPos : Vector;
		var i 		: int;
		var timePassed, timeWait : float;

		pos = this.GetWorldPosition();
		if (angle > 359.f) {
			FindGameplayEntitiesInRange(/*entities*/ entities, /*center*/ thePlayer, /*range*/ range, /*maxResults*/ 100000);
		} else {
			FindGameplayEntitiesInCone(/*entities*/ entities, /*center*/ thePlayer.GetWorldPosition(), /*coneDir*/ thePlayer.GetHeading(), /*coneAngle*/ angle, /*range*/ range, /*maxResults*/ 100000);
		}
		
		NR_Debug("NR_AardProjectile.NR_ProcessCollisionEntitiesInCone: " + entities.Size() + " targets");
		for (i = 0; i < entities.Size(); i += 1) {
			nodes.PushBack(entities[i]);
		}
		SortNodesByDistance(pos, nodes);

		timePassed = 0.f;
		for (i = 0; i < nodes.Size(); i += 1) {
			entity = (CGameplayEntity)nodes[i];
			actor = (CActor)entities[i];
			if (entity == thePlayer || (actor && actor.IsAlive() && GetAttitudeBetween(thePlayer, actor) != AIA_Hostile))
				continue;

			entityPos = entity.GetWorldPosition();
			if (AbsF(pos.Z - entityPos.Z) > 2.5f)
				continue;
			
			timeWait = VecDistance2D(pos, entityPos) / metersPerSec;
			NR_Debug("NR_ProcessCollisionEntitiesInCone: entity[" + i + "] = " + entity + ", timeWait = " + timeWait);
			timeWait -= timePassed;
			if (timeWait > 0.01f) {
				Sleep(timeWait);
				timePassed += timeWait;
			}
			ProcessCollisionOnEntity(entity);
		}
	}

	/*
	function PlayEffect( effectName : name, optional target : CNode  ) : bool {
		NR_Debug("AARD: PlayEffect: effectName = " + effectName);
		return super.PlayEffect(effectName, target);
	}

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		NR_Debug("AARD: OnAttackRangeHit: entity = " + entity);
		super.OnAttackRangeHit( entity );
	}
	*/
}