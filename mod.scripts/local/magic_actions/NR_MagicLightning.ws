class NR_MagicLightning extends NR_MagicAction {
	protected var entityTemplate2 	: CEntityTemplate;
	default actionType = ENR_Lightning;

	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 0);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			sceneInputs.PushBack(3);
			sceneInputs.PushBack(4);
			sceneInputs.PushBack(5);
			PlayScene( sceneInputs );
		}

		return true;
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_dummy_hit_fx");
		entityTemplate2 = (CEntityTemplate)LoadResourceAsync("nr_lightning_fx");
		// lightning can destroy clues //
		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 0.f );
		dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		if (!dummyEntity) {
			NRE("DummyEntity is invalid.");
			return OnPrepared(false);
		}
		//((CGameplayEntity)dummyEntity).AddTag( 'nr_lightning_dummy_entity' );
		dummyEntity.DestroyAfter( 5.f );
		m_fxNameMain = LightningFxName();
		m_fxNameHit = HitFxName(); // use dummy entity - more hit fx options

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var targetNPC : CNewNPC;
		var component : CComponent;
		var dk : float;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		if (target) {
			component = target.GetComponent('torso3effect');
			if (component) {
				thePlayer.PlayEffect(m_fxNameMain, component);
			} else {
				thePlayer.PlayEffect(m_fxNameMain, target);
			}

			targetNPC = (CNewNPC) target;
			if (!targetNPC || !targetNPC.HasAlternateQuen()) {
				dummyEntity.Teleport(target.GetWorldPosition() + Vector(0,0,1.f));
				dummyEntity.PlayEffect(m_fxNameHit);
			}
			thePlayer.OnCollisionFromItem(target);

			damage = new W3DamageAction in this;
			damage.Initialize( thePlayer, target, dummyEntity, thePlayer.GetName(), EHRT_Light, CPS_SpellPower, false, false, false, true );
			dk = 1.5f;
			damageVal = GetDamage(/*min*/ 1.f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/ /*customTarget*/);
			damage.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, damageVal );
			// damage.AddEffectInfo(EET_Burning, 2.0);
			theGame.damageMgr.ProcessAction( damage );
			delete damage;

			if (FactsQuerySum("nr_magic_LightningRebound") > 0) {
				Sleep(0.1f);
				OnPerformRebound(target);
			}
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

	latent function OnPerformRebound(oldTarget : CActor) {
		var lightningEntity, dummyEntity2 : CEntity;
		var actor : CActor;
		var targetNPC : CNewNPC;
		var entities : array<CGameplayEntity>;
		var i : int;
		var distSq, minDistSq, dk : float;
		var onLine : bool;
		var component : CComponent;

		minDistSq = 999999.f;
		FindGameplayEntitiesInRange(entities, oldTarget, 25.f, 99, , FLAG_ExcludePlayer + FLAG_OnlyAliveActors + FLAG_ExcludeTarget);
		target = NULL;
		for (i = 0; i < entities.Size(); i += 1) {
			actor = (CActor)entities[i];
			if (actor && actor != oldTarget) {
				distSq = VecDistanceSquared(oldTarget.GetWorldPosition(), actor.GetWorldPosition());
				NRD("OnPerformRebound: distSq = " + distSq + " actor = " + actor);
				if (distSq < minDistSq) {
					onLine = NR_OnLineOfSight(oldTarget, actor, 1.f);
					NRD("OnPerformRebound: onLine = " + onLine);
					if (onLine) {
						target = actor;
						minDistSq = distSq;
					}
				}
			}
		}

		if (target) {
			lightningEntity = theGame.CreateEntity( entityTemplate2, oldTarget.GetWorldPosition() + Vector(0,0,1.f), oldTarget.GetWorldRotation() );
			dummyEntity2 = theGame.CreateEntity( entityTemplate, target.GetWorldPosition() + Vector(0,0,1.f), target.GetWorldRotation() );

			component = targetNPC.GetComponent('torso3effect');
			if (component) {
				NRD("lightningEntity = " + lightningEntity + ", has effect = " + lightningEntity.HasEffect(m_fxNameMain) + ", play effect (" + component + ") = " + lightningEntity.PlayEffect(m_fxNameMain, component));
				//lightningEntity.PlayEffect(m_fxNameMain, component);
			} else {
				NRD("lightningEntity = " + lightningEntity + ", has effect = " + lightningEntity.HasEffect(m_fxNameMain) + ", play effect (" + target + ") = " + lightningEntity.PlayEffect(m_fxNameMain, target));
				//lightningEntity.PlayEffect(m_fxNameMain, target);
			}

			targetNPC = (CNewNPC)target;
			if (!targetNPC || !targetNPC.HasAlternateQuen() ) {
				dummyEntity2.Teleport(target.GetWorldPosition() + Vector(0,0,1.f));
				dummyEntity2.PlayEffect(m_fxNameHit);
			}
			thePlayer.OnCollisionFromItem(target);

			damage = new W3DamageAction in this;
			damage.Initialize( thePlayer, target, dummyEntity, thePlayer.GetName(), EHRT_Light, CPS_SpellPower, false, false, false, true );
			dk = 1.f;
			damageVal = GetDamage(/*min*/ 1.f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/ /*customTarget*/);
			damage.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, damageVal );
			// damage.AddEffectInfo(EET_Burning, 2.0);
			theGame.damageMgr.ProcessAction( damage );
			delete damage;
		}

		return;
	}

	latent function BreakAction() {
		if (isPerformed)
			return;
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.DestroyAfter(3.f);
		}
	}

	latent function HitFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_ThrowAbstract);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'hit_electric_yellow';
			case ENR_ColorOrange:
				return 'hit_electric_orange';
			case ENR_ColorRed:
				return 'hit_electric_red';
			case ENR_ColorPink:
				return 'hit_electric_pink';
			case ENR_ColorViolet:
				return 'hit_electric_violet';
			case ENR_ColorBlue:
				return 'hit_electric_blue';
			case ENR_ColorSeagreen:
				return 'hit_electric_seagreen';
			case ENR_ColorGreen:
				return 'hit_electric_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'hit_electric_white';
		}
	}

	latent function LightningFxName() : name {
		var color 	: ENR_MagicColor = NR_GetActionColor(ENR_ThrowAbstract);
		var fx_type : name			 = map[sign].getN("style_" + ENR_MAToName(actionType));
		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_yellow';
					case 'keira':
					default:
						return 'lightning_keira_yellow';
				}
			case ENR_ColorOrange:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_orange';
					case 'keira':
					default:
						return 'lightning_keira_orange';
				}
			case ENR_ColorRed:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_red';
					case 'keira':
					default:
						return 'lightning_keira_red';
				}
			case ENR_ColorPink:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_pink';
					case 'keira':
					default:
						return 'lightning_keira_pink';
				}
			case ENR_ColorViolet:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_violet';
					case 'keira':
					default:
						return 'lightning_keira_violet';
				}
			case ENR_ColorBlue:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_blue';
					case 'keira':
					default:
						return 'lightning_keira_blue';
				}
			case ENR_ColorSeagreen:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_seagreen';
					case 'keira':
					default:
						return 'lightning_keira_seagreen';
				}
			case ENR_ColorGreen:
				switch (fx_type) {
					case 'lynx':
						return 'lightning_lynx_green';
					case 'keira':
					default:
						return 'lightning_keira_green';
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
					case 'keira':
					default:
						//return 'lightning_keira_white';
						return 'lightning_sand';
				}
		}
	}
}
