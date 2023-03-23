class NR_AardProjectile extends W3AardProjectile {
	var entitiesToSlowdown 	: array<CNewNPC>;
	var useSlowdown			: bool;
	var useFreeze 			: bool;
	var useBurn 			: bool;
	/*event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		NRD("OnProjectileCollision: collidingComponent = " + collidingComponent);
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}*/

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var params : SCustomEffectParams;
		var target : CNewNPC;

		target = (CNewNPC)collider;
		if (target) {
			params.creator = thePlayer;
			params.duration = 10.f;
			params.sourceName = 'NR_AardProjectile';

			if (useFreeze) {
				params.effectType = EET_Frozen;
			} else if (useBurn) {
				params.effectType = EET_Burning;
			} else {
				params.effectType = EET_HeavyKnockdown;
				entitiesToSlowdown.PushBack(target);
			}
			target.AddEffectCustom(params);
		} else {
			super.ProcessCollision(collider, pos, normal);
		}

		NRD("ProcessCollision: collider = " + collider);
		//action.AddEffectInfo( EET_HeavyKnockdown );
		//super.ProcessCollision(collider, pos, normal);
	}

	timer function ProcessSlowdown( delta : float, id : int ) {
		var i : int;
		var params : SCustomEffectParams;

		params.creator = thePlayer;
		params.duration = 7.f;
		params.sourceName = 'NR_AardProjectile';
		params.effectType = EET_SlowdownAxii; // 0.7
		params.customFXName = 'axii_slowdown';

		NRD("ProcessSlowdown: entities: " + entitiesToSlowdown.Size());
		for (i = 0; i < entitiesToSlowdown.Size(); i += 1) {
			entitiesToSlowdown[i].AddEffectCustom(params);
			NRD("ProcessSlowdown: " + entitiesToSlowdown[i]);
		}
	}

	function PlayEffect( effectName : name, optional target : CNode  ) : bool {
		NRD("PlayEffect: effectName = " + effectName);
		return super.PlayEffect(effectName, target);
	}

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		NRD("OnAttackRangeHit: entity = " + entity);
		super.OnAttackRangeHit( entity );
	}
}