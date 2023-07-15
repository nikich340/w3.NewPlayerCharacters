class NR_MagicSlash extends NR_MagicAction {
	var dummyEntity2 : CEntity;
	var swingType, swingDir	: int;
	
	default actionType = ENR_Slash;
	default actionSubtype = ENR_LightAbstract;
	default performsToLevelup = 100;

	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 5);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			sceneInputs.PushBack(3);
			sceneInputs.PushBack(4);
			sceneInputs.PushBack(5);
			PlayScene( sceneInputs );
		}

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("DoubleSlash");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function SetSwingData(newSwingType : int, newSwingDir : int) {
		swingType = newSwingType;
		swingDir = newSwingDir;
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		resourceName = SlashEntityName();
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );
		if ( IsActionAbilityUnlocked("DoubleSlash") ) {
			pos.Z += 0.15f;
			dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
			pos.Z -= 0.3f;
			dummyEntity2 = theGame.CreateEntity( entityTemplate, pos, rot );
		} else {
			dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		}

		m_fxNameMain = SlashFxName();
		if (dummyEntity && m_fxNameMain != '') {
			dummyEntity.PlayEffect(m_fxNameMain);
			dummyEntity.DestroyAfter(5.f);
			if (dummyEntity2) {
				dummyEntity2.PlayEffect(m_fxNameMain);
				dummyEntity2.DestroyAfter(5.f);
			}
		} else {
			NRE("DummyEntity (" + resourceName + ", " + entityTemplate + ", " + dummyEntity + ") or m_fxNameMain (" + m_fxNameMain + ") is invalid.");
			return OnPrepared(false);
		}

		return OnPrepared(true);
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
		var targetNPC : CNewNPC;
		var dk : float;

		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false, scriptedPerform);
		}
		if (target) {
			targetNPC = (CNewNPC) target;
			targetNPC.NoticeActor( thePlayer );
			if ( m_fxNameHit != '' && (!targetNPC || !targetNPC.HasAlternateQuen()) ) {
				dummyEntity.PlayEffect(m_fxNameHit);
				if (dummyEntity2) {
					dummyEntity2.PlayEffect(m_fxNameHit);
				}
			}
			thePlayer.OnCollisionFromItem( target );

			damage = new W3DamageAction in this;
			damage.Initialize( thePlayer, target, dummyEntity, thePlayer.GetName(), EHRT_Light, CPS_SpellPower, false, false, false, true );
			if (dummyEntity2) {
				dk = 1.5f * SkillTotalDamageMultiplier();
			} else {
				dk = 1.f * SkillTotalDamageMultiplier();
			}
			damageVal = GetDamage(/*min*/ 1.f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/ /*customTarget*/);
			damage.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, damageVal );
			// damage.AddEffectInfo(EET_Burning, 2.0);
			theGame.damageMgr.ProcessAction( damage );
			delete damage;
		}
		/* else if (destroyable) {
			if (destroyable.reactsToIgni) {
				destroyable.OnIgniHit(NULL);
			} else {
				destroyable.OnAardHit(NULL);
			}
		}
		*/

		return OnPerformed(true, scriptedPerform);
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
						return 'down_left_special1';
					case ASD_RightLeft:
					default:
						return 'down_right_special1';
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
}
