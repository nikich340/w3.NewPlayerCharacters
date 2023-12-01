class NR_MagicRipApart extends NR_MagicAction {
	default actionType = ENR_RipApart;
	default actionSubtype = ENR_HeavyAbstract;

	latent function OnInit() : bool {
		sceneInputs.PushBack(6);
		sceneInputs.PushBack(7);
		super.OnInit();

		return true;
	}

	latent function OnPrepare() : bool {
		var buffParams : SCustomEffectParams;
		super.OnPrepare();

		if (target) {
			buffParams.effectType = EET_Confusion;
			buffParams.creator = thePlayer;
			buffParams.sourceName = 'NR_MagicRipApart';
			buffParams.duration = 7.f;
			buffParams.customFXName = 'axii_slowdown';
			target.AddEffectCustom(buffParams);

			entityTemplate = (CEntityTemplate)LoadResourceAsync("blood_explode");
			NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ false, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 0.f );
			dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		}

		return OnPrepared(true);
	}
	latent function OnPerform() : bool {
		var dismembermentComp 	: CDismembermentComponent;
		var wounds				: array< name >;
		var usedWound			: name;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		if (target) {
			dismembermentComp = (CDismembermentComponent)(target.GetComponentByClassName( 'CDismembermentComponent' ));
			if(!dismembermentComp) {
				NRD("NR_MagicRipApart: target <" + target + "> has no dismembermentComp.");
				dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );
	
				if ( wounds.Size() > 0 )
					usedWound = wounds[ NR_GetRandomGenerator().next( wounds.Size() ) ];
						
				target.SetDismembermentInfo( usedWound, Vector( 0, 0, 10 ), /*forceRagdoll*/ true );
				target.AddTimer( 'DelayedDismemberTimer', 0.05f );
			}
			thePlayer.OnCollisionFromItem( target );

			dummyEntity.PlayEffect('blood_explode');
			dummyEntity.DestroyAfter(5.f);
			target.Kill('NR_MagicRipApart', true, thePlayer);
		}

		return OnPerformed(true);
	}
	latent function BreakAction() {
		if (isPerformed)
			return;
			
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.Destroy();
		}
	}
}
