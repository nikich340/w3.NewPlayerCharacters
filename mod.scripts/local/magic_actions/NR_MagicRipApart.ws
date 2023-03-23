class NR_MagicRipApart extends NR_MagicAction {
	default actionType = ENR_RipApart;

	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 0);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			sceneInputs.PushBack(6);
			sceneInputs.PushBack(7);
			PlayScene( sceneInputs );
		}

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
					usedWound = wounds[ RandRange( wounds.Size() ) ];
						
				target.SetDismembermentInfo( usedWound, Vector( 0, 0, 10 ), /*forceRagdoll*/ true );
				target.AddTimer( 'DelayedDismemberTimer', 0.05f );
			}
			thePlayer.OnCollisionFromItem( target );

			dummyEntity.PlayEffect('blood_explode');
			dummyEntity.DestroyAfter(5.f);
			target.Kill('NR_ReplacerSorceress', false, thePlayer);
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
