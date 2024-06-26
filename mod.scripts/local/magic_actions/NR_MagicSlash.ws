class NR_MagicSlash extends NR_MagicAction {
	protected var entityTemplate2 	: CEntityTemplate;
	protected var dummyEntity2, hitEntity, hitEntity2 : CEntity;
	protected var swingType, swingDir	: int;
	
	default actionType = ENR_Slash;
	default actionSubtype = ENR_LightAbstract;
	default performsToLevelup = 100;

	latent function OnInit() : bool {
		sceneInputs.PushBack(3);
		sceneInputs.PushBack(4);
		sceneInputs.PushBack(5);
		super.OnInit();

		return true;
	}

	latent function SetSwingData(newSwingType : int, newSwingDir : int) {
		swingType = newSwingType;
		swingDir = newSwingDir;
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		resourceName = SlashEntityName();
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
		entityTemplate2 = (CEntityTemplate)LoadResourceAsync("nr_dummy_hit_fx");

		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );
		if ( IsActionAbilityEnabled("DoubleSlash") ) {
			pos.Z += 0.15f;
			dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
			pos.Z -= 0.3f;
			dummyEntity2 = theGame.CreateEntity( entityTemplate, pos, rot );
		} else {
			dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		}
		hitEntity = theGame.CreateEntity( entityTemplate2, pos, rot );
		hitEntity.DestroyAfter( 5.f );

		m_fxNameMain = SlashFxName();
		m_fxNameHit = HitFxName();

		if (dummyEntity && IsNameValid(m_fxNameMain)) {
			dummyEntity.PlayEffect(m_fxNameMain);
			dummyEntity.DestroyAfter(5.f);
			if (dummyEntity2) {
				hitEntity2 = theGame.CreateEntity( entityTemplate2, pos, rot );
				hitEntity2.DestroyAfter( 5.f );

				dummyEntity2.PlayEffect(m_fxNameMain);
				dummyEntity2.DestroyAfter(5.f);
			}
		} else {
			NR_Error("DummyEntity (" + resourceName + ", " + entityTemplate + ", " + dummyEntity + ") or m_fxNameMain (" + m_fxNameMain + ") is invalid.");
			return OnPrepared(false);
		}

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var typeName : name = map[sign].getN("style_" + ENR_MAToName(actionType));
		var targetNPC : CNewNPC;
		var dk : float;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}
		if (target) {
			targetNPC = (CNewNPC) target;
			targetNPC.NoticeActor( thePlayer );
			if ( IsNameValid(m_fxNameHit) && (!targetNPC || !targetNPC.HasAlternateQuen()) ) {
				hitEntity.Teleport(target.GetWorldPosition() + Vector(0,0,1.f));
				hitEntity.PlayEffect(m_fxNameHit);
				if (typeName == 'triss')
					targetNPC.PlayEffect('fire_hit');
				
				if (hitEntity2) {
					hitEntity2.Teleport(target.GetWorldPosition() + Vector(0,0,1.f - 0.3f));
					hitEntity2.PlayEffect(m_fxNameHit);
				}
			}
			// thePlayer.OnCollisionFromItem( target );

			damage = new W3DamageAction in this;
			damage.Initialize( thePlayer, target, dummyEntity, thePlayer.GetName(), EHRT_Light, CPS_SpellPower, false, false, false, true );
			if (dummyEntity2) {
				dk = 1.25f * SkillTotalDamageMultiplier();
			} else {
				dk = 1.f * SkillTotalDamageMultiplier();
			}
			damageVal = NR_GetDamageGeneric("NR_MagicSlash", thePlayer, target, /*min*/ 1.5f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/);
			AddMagicDamage(damage, damageVal);
			theGame.damageMgr.ProcessAction( damage );
			delete damage;
		} else if (destroyableTarget) {
			hitEntity.PlayEffect(m_fxNameHit);
			if (hitEntity2) {
				hitEntity2.PlayEffect(m_fxNameHit);
			}
			NR_DestroyDestroyableTarget();

		}
		// explodes toxic gas
		dummyEntity.AddTag(theGame.params.TAG_OPEN_FIRE);

		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;
			
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.Destroy();
		}
		if (dummyEntity2) {
			dummyEntity2.Destroy();
		}
	}

	latent function SlashEntityName() : String
	{
		var typeName : name = map[sign].getN("style_" + ENR_MAToName(actionType));
		switch (typeName) {
			case 'triss':
				return "nr_triss_slash";
			case 'philippa':
				return "nr_philippa_slash";
			case 'lynx':
				return "nr_lynx_slash";
			case 'yennefer':
			default:
				return "nr_yennefer_slash";
		}
	}
	
	latent function SlashFxName() : name 
	{
		var color : ENR_MagicColor = NR_GetActionColor();
		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_yellow';
					case ASD_RightLeft:
					default:
						return 'down_right_yellow';
				}
			case ENR_ColorOrange:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_orange';
					case ASD_RightLeft:
					default:
						return 'down_right_orange';
				}
			case ENR_ColorRed:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_red';
					case ASD_RightLeft:
					default:
						return 'down_right_red';
				}
			case ENR_ColorPink:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_pink';
					case ASD_RightLeft:
					default:
						return 'down_right_pink';
				}
			case ENR_ColorViolet:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_violet';
					case ASD_RightLeft:
					default:
						return 'down_right_violet';
				}
			case ENR_ColorBlue:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_blue';
					case ASD_RightLeft:
					default:
						return 'down_right_blue';
				}
			case ENR_ColorSeagreen:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_seagreen';
					case ASD_RightLeft:
					default:
						return 'down_right_seagreen';
				}
			case ENR_ColorGreen:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_green';
					case ASD_RightLeft:
					default:
						return 'down_right_green';
				}
			case ENR_ColorSpecial1:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_transparent';
					case ASD_RightLeft:
					default:
						return 'down_right_transparent';
				}
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				switch ( swingDir ) {
					case ASD_LeftRight:
						return 'down_left_white';
					case ASD_RightLeft:
					default:
						return 'down_right_white';
				}
		}
	}

	latent function HitFxName(optional customActionType : ENR_MagicAction) : name {
		var typeName : name = map[sign].getN("style_" + ENR_MAToName(actionType));

		switch (NR_GetActionColor(actionType)) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				// return 'fire_hit_yellow';
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
}
