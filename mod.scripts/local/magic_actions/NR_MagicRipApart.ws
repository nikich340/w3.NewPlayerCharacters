class NR_MagicRipApart extends NR_MagicAction {
	default actionType = ENR_RipApart;

	latent function onPrepare() : bool {
		var buffParams : SCustomEffectParams;
		super.onPrepare();

		if (target) {
			buffParams.effectType = EET_Confusion;
			buffParams.creator = thePlayer;
			buffParams.sourceName = 'NR_ReplacerSorceress';
			buffParams.duration = 6.f;
			buffParams.customFXName = 'axii_slowdown';
			target.AddEffectCustom(buffParams);

			entityTemplate = (CEntityTemplate)LoadResourceAsync("blood_explode");
			NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ false, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 0.f );
			dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		}

		return onPrepared(true);
	}
	latent function onPerform() : bool {
		var dismembermentComp 	: CDismembermentComponent;
		var wounds				: array< name >;
		var usedWound			: name;

		var super_ret : bool;
		super_ret = super.onPerform();
		if (!super_ret) {
			return onPerformed(false);
		}

		if (target) {
			dismembermentComp = (CDismembermentComponent)(target.GetComponentByClassName( 'CDismembermentComponent' ));
			if(!dismembermentComp) {
				NRD("NR_MagicRipApart: target <" + target + "> has no dismembermentComp.");
				dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );
	
				if ( wounds.Size() > 0 )
					usedWound = wounds[ RandRange( wounds.Size() ) ];
						
				target.SetDismembermentInfo( usedWound, Vector( 0, 0, 10 ), /*forceRagdoll*/ true );
				target.AddTimer( 'DelayedDismemberTimer', 0.05f );
			}
			thePlayer.OnCollisionFromItem( target );

			dummyEntity.PlayEffect('blood_explode');
			dummyEntity.DestroyAfter(5.f);
			//target.Kill('NR_ReplacerSorceress');
		}

		return onPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.Destroy();
		}
	}
}
