class NR_MagicLightning extends NR_MagicAction {
	default actionType = ENR_Lightning;

	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 20);
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
		super.OnPrepare();

		entityTemplate = (CEntityTemplate)LoadResourceAsync("fx_dummy_entity");
		// lightning can destroy clues //
		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 0.f );
		dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		if (!dummyEntity) {
			NRE("DummyEntity is invalid.");
			return OnPrepared(false);
		}
		((CGameplayEntity)dummyEntity).AddTag( 'nr_lightning_dummy_entity' );
		dummyEntity.DestroyAfter( 3.f );

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var targetNPC : CNewNPC;
		var component : CComponent;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		m_fxNameMain = LightningFxName();
		// m_fxNameHit = set from MagicManager
		if (target) {
			component = target.GetComponent('torso3effect');
			if (component) {
				thePlayer.PlayEffect(m_fxNameMain, component);
			} else {
				thePlayer.PlayEffect(m_fxNameMain, target);
			}

			targetNPC = (CNewNPC) target;
			if ( m_fxNameHit != '' && (!targetNPC || !targetNPC.HasAlternateQuen()) ) {
				dummyEntity.PlayEffect(m_fxNameHit);
			}
			thePlayer.OnCollisionFromItem(target);
		} else if (destroyable) {
			if (destroyable.reactsToIgni) {
				destroyable.OnIgniHit(NULL);
			} else {
				destroyable.OnAardHit(NULL);
			}
			thePlayer.PlayEffect(m_fxNameMain, destroyable);
			dummyEntity.PlayEffect(m_fxNameHit);
		} else {
			thePlayer.PlayEffect(m_fxNameMain, dummyEntity);
			dummyEntity.PlayEffect(m_fxNameHit);
		}

		return OnPerformed(true);
	}

	latent function BreakAction() {
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.DestroyAfter(3.f);
		}
	}

	latent function LightningFxName() : name {
		var color 	: ENR_MagicColor = NR_GetActionColor();
		var fx_type : name			 = map[sign].getN("fx_type_" + ENR_MAToName(actionType));
		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_yellow';
					case 'yennefer':
					default:
						return 'lightning_yennefer_yellow';
				}
			case ENR_ColorOrange:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_orange';
					case 'yennefer':
					default:
						return 'lightning_yennefer_orange';
				}
			case ENR_ColorRed:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_red';
					case 'yennefer':
					default:
						return 'lightning_yennefer_red';
				}
			case ENR_ColorPink:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_pink';
					case 'yennefer':
					default:
						return 'lightning_yennefer_pink';
				}
			case ENR_ColorViolet:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_violet';
					case 'yennefer':
					default:
						return 'lightning_yennefer_violet';
				}
			case ENR_ColorBlue:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_blue';
					case 'yennefer':
					default:
						return 'lightning_yennefer_blue';
				}
			case ENR_ColorSeagreen:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_seagreen';
					case 'yennefer':
					default:
						return 'lightning_yennefer_seagreen';
				}
			case ENR_ColorGreen:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_green';
					case 'yennefer':
					default:
						return 'lightning_yennefer_green';
				}
			//case ENR_ColorSpecial1:
			//	return 'ENR_ColorSpecial1';
			//case ENR_ColorSpecial2:
			//	return 'ENR_ColorSpecial2';
			//case ENR_ColorSpecial3:
			//	return 'ENR_ColorSpecial3';
			case ENR_ColorWhite:
			default:	
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_white';
					case 'yennefer':
					default:
						return 'lightning_yennefer_white';
				}
		}
	}
}
