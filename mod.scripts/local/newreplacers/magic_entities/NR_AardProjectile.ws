class NR_AardProjectile extends W3AardProjectile {
	var targetEntities 		: array<CGameplayEntity>;
	var useSlowdown			: bool;
	var useFreeze 			: bool;
	var useBurn 			: bool;
	var useFullSphere 		: bool;
	
	/*event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		// NR_Debug("OnProjectileCollision: collidingComponent = " + collidingComponent);
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}*/

	protected function ProcessCollisionOnEntity( target : CGameplayEntity ) {
		var params, params2 : SCustomEffectParams;
		var npc  	: CNewNPC;
		var buffResult 	: EEffectInteract;
		var i 			: int;
		var effectTypes : array<EEffectType>;

		if (targetEntities.FindFirst(target) > -1)
			return;

		targetEntities.PushBack(target);

		npc = (CNewNPC)target;
		if (!npc) {
			target.OnAardHit( this );
			return;
		}

		params.creator = thePlayer;
		params.sourceName = 'NR_AardProjectile';
		//params.effectValue.valueAdditive = 50.f + 20.f * npc.GetLevel();
		params.effectValue.valueBase = 1000.f;
		params.effectValue.valueMultiplicative = 1.1f;
		params.effectValue.valueAdditive = 1000.f;
		params.customPowerStatValue.valueBase = 1000.f;
		params.customPowerStatValue.valueMultiplicative = 1.1f;
		params.customPowerStatValue.valueAdditive = 1000.f;
		params.duration = 2.f + 0.2f * (int)NR_GetMagicManager().GetSkillLevel() + 0.1f * NR_GetMagicManager().GetActionSkillLevel(ENR_CounterPush);

		effectTypes.PushBack(EET_HeavyKnockdown);
		effectTypes.PushBack(EET_Knockdown);
		effectTypes.PushBack(EET_KnockdownTypeApplicator);
		effectTypes.PushBack(EET_LongStagger);
		effectTypes.PushBack(EET_Stagger);

		for (i = 0; i < effectTypes.Size(); i += 1) {
			params.effectType = effectTypes[i];
			// remove old to prevent cumulating
			// npc.RemoveBuff(effectTypes[i]);
			buffResult = npc.AddEffectCustom(params);
			if (buffResult != EI_Deny) {
				NR_Info("NR_AardProjectile.ProcessCollisionOnEntity: buffPassed = " + effectTypes[i] + ", npc = " + npc);
				// success
				// NR_Debug("ProcessCollisionOnEntity: " + buffResult + " (" + effectTypes[i] + "), npc = " + npc);
				break;
			}
			params.duration += 0.3f;
		}

		if (useFreeze || useBurn) {
			params2.creator = thePlayer;
			params2.sourceName = 'NR_AardProjectile';
			params2.duration = 3.f + 0.3f * (int)NR_GetMagicManager().GetSkillLevel() + 0.15f * NR_GetMagicManager().GetActionSkillLevel(ENR_CounterPush);
			if (useFreeze) {
				params2.effectType = EET_Frozen;
			} else {
				params2.effectType = EET_Burning;
			}
			npc.AddEffectCustom(params2);
			return;
		}
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var target : CNewNPC;

		// NR_Debug("AARD: ProcessCollision: collider = " + collider);
		target = (CNewNPC)collider;
		if (target && target.IsAlive()) {
			if (useFullSphere) {
				ProcessCollisionOnEntity(target);
			}
			// CONE: do nothing - target is processed by ProcessCollisionNPCsInCone
		} else {
			super.ProcessCollision(collider, pos, normal);
		}

		// NR_Debug("AARD: ProcessCollision: target = " + target);
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

		// NR_Debug("AARD: ProcessSlowdown: entities: " + targetEntities.Size());
		for (i = 0; i < targetEntities.Size(); i += 1) {
			targetEntities[i].AddEffectCustom(params);
			// NR_Debug("AARD: ProcessSlowdown: " + targetEntities[i]);
		}
	}
	*/

	latent function NR_ProcessCollisionNPCsInCone_OLD(range : float, angle : float, metersPerSec : float) {
		var actors 	: array <CActor>;
		var nodes 	: array <CNode>;
		var npc 	: CNewNPC;
		var pos, npcPos : Vector;
		var i 		: int;
		var timePassed, timeWait : float;

		pos = this.GetWorldPosition();
		if (angle > 359.f) {
			//actors = thePlayer.GetNPCsAndPlayersInRange(/*range*/ range, , , /*flags*/ FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile);
		} else {
			//actors = thePlayer.GetNPCsAndPlayersInCone(/*range*/ range, /*coneDir*/ thePlayer.GetHeading(), /*coneAngle*/ angle, , , /*flags*/ FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile);
		}
		
		// NR_Debug("AARD: " + actors.Size() + " targets");
		for (i = 0; i < actors.Size(); i += 1) {
			nodes.PushBack(actors[i]);
			// NR_Debug("actors[" + i + "] = " + actors[i]);
		}
		SortNodesByDistance(pos, nodes);

		timePassed = 0.f;
		for (i = 0; i < nodes.Size(); i += 1) {
			npc = (CNewNPC)nodes[i];
			npcPos = npc.GetWorldPosition();
			if (!npc || !npc.IsAlive() || AbsF(pos.Z - npcPos.Z) > 4.f)
				continue;
			
			timeWait = VecDistance2D(pos, npcPos) / metersPerSec;
			// NR_Debug("npc[" + i + "] = " + npc + ", timeWait = " + timeWait);
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
		
		// NR_Debug("NR_AardProjectile.NR_ProcessCollisionEntitiesInCone: " + entities.Size() + " targets");
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
			if (AbsF(pos.Z - entityPos.Z) > 3.f)
				continue;
			
			timeWait = VecDistance2D(pos, entityPos) / metersPerSec;
			// NR_Debug("NR_ProcessCollisionEntitiesInCone: entity[" + i + "] = " + entity + ", timeWait = " + timeWait);
			timeWait -= timePassed;
			if (timeWait > 0.01f) {
				Sleep(timeWait);
				timePassed += timeWait;
			}
			ProcessCollisionOnEntity(entity);
		}
	}
}