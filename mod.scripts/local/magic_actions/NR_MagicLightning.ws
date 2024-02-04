class NR_MagicLightning extends NR_MagicAction {
	protected var entityTemplate2 	: CEntityTemplate;
	protected var s_rebound 		: bool;
	
	default actionType = ENR_Lightning;
	default actionSubtype = ENR_ThrowAbstract;

	latent function OnInit() : bool {
		sceneInputs.PushBack(3);
		sceneInputs.PushBack(4);
		sceneInputs.PushBack(5);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("Rebound");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_dummy_hit_fx");
		entityTemplate2 = (CEntityTemplate)LoadResourceAsync("nr_lightning_fx");
		// lightning can destroy destructible //
		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 0.f );
		dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		if (!dummyEntity) {
			NR_Error("DummyEntity is invalid.");
			return OnPrepared(false);
		}
		s_rebound = !isScripted && IsActionAbilityUnlocked("Rebound");
		dummyEntity.DestroyAfter( 5.f );
		m_fxNameMain = LightningFxName();
		m_fxNameHit = HitFxName();
		// m_fxNameExtra = ... for rebounding ?

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var targetNPC : CNewNPC;
		var oldTarget : CActor;
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

			Sleep(0.1f);
			targetNPC = (CNewNPC) target;
			if ( !targetNPC || !targetNPC.HasAlternateQuen() ) {
				dummyEntity.Teleport(target.GetWorldPosition() + Vector(0,0,1.f));
				dummyEntity.PlayEffect(m_fxNameHit);
			}
			//thePlayer.OnCollisionFromItem(target);

			damage = new W3DamageAction in this;
			damage.Initialize( thePlayer, target, dummyEntity, thePlayer.GetName(), EHRT_Light, CPS_SpellPower, false, false, false, true );
			dk = 1.5f * SkillTotalDamageMultiplier();
			damageVal = GetDamage(/*min*/ 1.5f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/ /*customTarget*/);
			damage.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, damageVal * 0.5f );
			damage.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, damageVal * 0.5f );
			damage.AddEffectInfo(EET_Stagger, 2.f);
			theGame.damageMgr.ProcessAction( damage );
			delete damage;

			if (s_rebound) {
				Sleep(0.1f);
				oldTarget = target;
				target = FindNewTarget(oldTarget, 20.f);
				NR_Debug("Rebound: newTarget = " + target);
				if (target)
					OnPerformReboundFromActor(target, oldTarget);
			}
		} else if (destroyableTarget) {
			thePlayer.PlayEffect(m_fxNameMain, destroyableTarget);
			dummyEntity.PlayEffect(m_fxNameHit);
			NR_DestroyDestroyableTarget();
		} else {
			thePlayer.PlayEffect(m_fxNameMain, dummyEntity);
			dummyEntity.PlayEffect(m_fxNameHit);
		}
		// explodes toxic gas
		dummyEntity.AddTag(theGame.params.TAG_OPEN_FIRE);
		dummyEntity.DestroyAfter(5.f);

		return OnPerformed(true);
	}

	latent function OnPerformReboundFromPos(newTarget : CActor, fromPos : Vector) {
		var lightningEntity, dummyEntity2 : CEntity;
		var entities 		: array<CGameplayEntity>;
		var i				: int;
		var capsuleHeight   : float;
		var component : CComponent;
		var targetNPC : CNewNPC;
		var dk : float;

		if (!newTarget)
			return;

		lightningEntity = theGame.CreateEntity( entityTemplate2, fromPos );
		
		if (newTarget.IsAlive())
			capsuleHeight = ((CMovingPhysicalAgentComponent)newTarget.GetMovingAgentComponent()).GetCapsuleHeight();
		else
			capsuleHeight = 0.f;

		dummyEntity2 = theGame.CreateEntity( entityTemplate, newTarget.GetWorldPosition() + Vector(0,0,capsuleHeight * 0.9f) );
		
		component = newTarget.GetComponent('torso3effect');
		if (component) {
			lightningEntity.PlayEffect(m_fxNameMain, component);
		} else {
			lightningEntity.PlayEffect(m_fxNameMain, newTarget);
		}

		Sleep(0.2f);
		targetNPC = (CNewNPC)newTarget;
		if ( !targetNPC || !targetNPC.HasAlternateQuen() ) {
			dummyEntity2.PlayEffect(m_fxNameHit);
		}
		//thePlayer.OnCollisionFromItem(newTarget);

		damage = new W3DamageAction in this;
		damage.Initialize( thePlayer, newTarget, dummyEntity, thePlayer.GetName(), EHRT_Light, CPS_SpellPower, false, false, false, true );
		dk = 1.f * SkillTotalDamageMultiplier();
		damageVal = GetDamage(/*min*/ 1.f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/ /*customTarget*/);
		damage.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, damageVal * 0.5f );
		damage.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, damageVal * 0.5f );
		damage.AddEffectInfo(EET_Stagger, 1.f);
		theGame.damageMgr.ProcessAction( damage );
		delete damage;
		lightningEntity.DestroyAfter(5.f);
		dummyEntity2.DestroyAfter(5.f);
	}

	// Just a visual fx
	latent function OnPerformReboundFromPosToPos(newPos : Vector, fromPos : Vector, playHitFx : bool) {
		var lightningEntity, dummyEntity2 : CEntity;
		var entities 		: array<CGameplayEntity>;
		var i				: int;

		lightningEntity = theGame.CreateEntity( entityTemplate2, fromPos );
		dummyEntity2 = theGame.CreateEntity( entityTemplate, newPos );
		
		lightningEntity.PlayEffect(m_fxNameMain, dummyEntity2);
		if (playHitFx) {
			Sleep(0.3f);
			dummyEntity2.PlayEffect(m_fxNameHit);
		}

		lightningEntity.DestroyAfter(5.f);
		dummyEntity2.DestroyAfter(5.f);
	}

	latent function OnPerformReboundFromActor(newTarget : CActor, oldTarget : CActor) {
		OnPerformReboundFromPos(newTarget, oldTarget.GetWorldPosition());
	}

	latent function FindNewTarget(oldTarget : CActor, searchRange : float) : CActor {
		var actor, newTarget : CActor;
		var entities : array<CGameplayEntity>;
		var i : int;
		var distSq, minDistSq, dk : float;
		var onLine : bool;

		// search for target
		minDistSq = 999999.f;
		FindGameplayEntitiesInRange(entities, oldTarget, searchRange, 99, , FLAG_ExcludePlayer + FLAG_OnlyAliveActors + FLAG_ExcludeTarget);
		newTarget = NULL;
		for (i = 0; i < entities.Size(); i += 1) {
			actor = (CActor)entities[i];
			if (actor && actor != oldTarget && GetAttitudeBetween(thePlayer, actor) == AIA_Hostile) {
				distSq = VecDistanceSquared(oldTarget.GetWorldPosition(), actor.GetWorldPosition());
				NR_Debug("OnPerformRebound: distSq = " + distSq + " actor = " + actor);
				if (distSq < minDistSq) {
					onLine = NR_OnLineOfSight(oldTarget, actor, 1.f);
					NR_Debug("OnPerformRebound: onLine = " + onLine);
					if (onLine) {
						newTarget = actor;
						minDistSq = distSq;
					}
				}
			}
		}

		return newTarget;
	}

	latent function BreakAction() {
		if (isPerformed)
			return;
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.DestroyAfter(3.f);
		}
	}

	latent function HitFxName(optional customActionType : ENR_MagicAction) : name {
		var color : ENR_MagicColor;
		if (customActionType != ENR_Unknown)
			color = NR_GetActionColor(customActionType);
		else
			color = NR_GetActionColor(ENR_ThrowAbstract);

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

	latent function LightningFxName(optional customActionType : ENR_MagicAction) : name {
		var color 	: ENR_MagicColor;
		var fx_type : name			 = map[sign].getN("style_" + ENR_MAToName(actionType));
		if (customActionType != ENR_Unknown)
			color = NR_GetActionColor(customActionType);
		else
			color = NR_GetActionColor(ENR_ThrowAbstract);
		
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
						return 'lightning_keira_white';
				}
		}
	}
}
