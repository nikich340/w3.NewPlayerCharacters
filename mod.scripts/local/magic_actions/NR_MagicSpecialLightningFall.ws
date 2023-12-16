statemachine class NR_MagicSpecialLightningFall extends NR_MagicSpecialAction {
	protected var entityTemplate2 : CEntityTemplate;
	protected var lightningEntity : CGameplayEntity;
	protected var s_respectCaster: bool;
	protected var s_lightningNum : int;
	protected var s_interval 	  : float;
	protected var meteor 		  : NR_MeteorProjectile;
	protected var savedWeather 	  : name;

	default actionType = ENR_SpecialLightningFall;
	default actionSubtype = ENR_SpecialAbstractAlt;
	default drainStaminaOnPerform = false;

	latent function OnInit() : bool {
		sceneInputs.PushBack(14);
		sceneInputs.PushBack(15);
		sceneInputs.PushBack(16);
		sceneInputs.PushBack(17);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("DamageControl");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		if (IsInSetupScene()) {
			s_lifetime = 3.f;
		} else {
			s_lifetime = 0.2f;
		}
		s_interval = 0.15f;

		entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_dummy_hit_fx");
		entityTemplate2 = (CEntityTemplate)LoadResourceAsync("nr_lightning_fx");
		
		m_fxNameMain = LightningFxName();
		m_fxNameHit = HitFxName();
		NR_Debug("ENR_SpecialLightningFall: m_fxNameMain = " + m_fxNameMain + ", m_fxNameHit = " + m_fxNameHit);
		
		s_respectCaster = IsActionAbilityUnlocked("DamageControl");
		s_lightningNum = SkillMaxApplies();
		savedWeather = GetWeatherConditionName();
		RequestWeatherChangeTo('WT_Rain_Storm', 1.f, false);

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var ret, super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		// unwanted actions may break anim
		thePlayer.BlockAction( EIAB_Movement, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Jump, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Roll, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Dodge, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Fists, 'TryPeformLongMagicAttack' );
		thePlayer.BlockAction( EIAB_Signs, 'TryPeformLongMagicAttack' );
	
		GotoState('Active');
		
		return OnPerformed(true);
	}

	latent function BreakAction() {
		super.BreakAction();

		GotoState('Stop');
	}

	public function ContinueAction() {
		s_lifetime = 0.2f;
	}
	
	latent function ShootLightning(cursed : bool, center : Vector) : bool {
		var dk : float;
		var thunderboltRange : float = 1.75f;
		var minRange : float = 2.5f;  // > thunderboltRange
		var maxRange : float = 12.f;
		var capsuleHeight : float;
		var entities 	: array<CGameplayEntity>;
		var component 	: CComponent;
		var targetTemp 	: CActor;
		var targetNPC 	: CNewNPC;
		var i 		 	: int;
		var damage 		: W3DamageAction;

		pos = center;
		if (cursed)
			pos += VecRingRand(0.f, minRange);
		else
			pos += VecRingRand(minRange, maxRange);
		pos = SnapToGround(pos);
		pos.Z += 40.f;
		lightningEntity = (CGameplayEntity)theGame.CreateEntity(entityTemplate2, pos);
		pos.Z -= 40.f;

		dummyEntity = (CEntity)theGame.CreateEntity( entityTemplate, pos, rot );
		
		target = NULL;
		FindGameplayEntitiesInCylinder( entities, pos, thunderboltRange, 2.f, 99, , FLAG_ExcludeTarget, lightningEntity );
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			targetTemp = (CActor)entities[i];
			if (targetTemp && (cursed || !s_respectCaster || targetTemp != thePlayer)) {
				target = targetTemp;

				if (target.IsAlive())
					break;
			}
		}
		
		NR_Debug("ENR_SpecialLightningFall: target = " + target);
		if (target) {
			targetNPC = (CNewNPC)target;
			// if target can't have quen (not NPC) or doesn't have quen - play hit fx
			if ( !targetNPC || !targetNPC.HasAlternateQuen() ) {
				if (target.IsAlive()) {
					capsuleHeight = ((CMovingPhysicalAgentComponent)target.GetMovingAgentComponent()).GetCapsuleHeight();
					dummyEntity.Teleport(target.GetWorldPosition() + Vector(0,0,capsuleHeight * 0.9f));
				}
				dummyEntity.PlayEffect(m_fxNameHit);
			}
			component = target.GetComponent('torso3effect');
			if (component) {
				lightningEntity.PlayEffect(m_fxNameMain, component);
			} else {
				lightningEntity.PlayEffect(m_fxNameMain, target);
			}
			
			damage = new W3DamageAction in this;
			damage.Initialize( thePlayer, target, dummyEntity, thePlayer.GetName(), EHRT_Light, CPS_SpellPower, false, false, false, true );
			dk = 1.f * SkillTotalDamageMultiplier();
			damageVal = GetDamage(/*min*/ 1.f*dk, /*max*/ 60.f*dk, /*vitality*/ 25.f*dk, 8.f*dk, /*essence*/ 90.f*dk, 12.f*dk /*randRange*/ /*customTarget*/);
			damage.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, damageVal );
			damage.AddEffectInfo(EET_Stagger, 1.f);
			theGame.damageMgr.ProcessAction( damage );
			delete damage;
		} else {
			component = dummyEntity.GetComponent('CEffectDummyComponent0');
			if (component) {
				lightningEntity.PlayEffect(m_fxNameMain, component);
				NR_Debug("Component = " + component);
			} else {
				lightningEntity.PlayEffect(m_fxNameMain, dummyEntity);
				NR_Debug("Component NULL = " + component);
			}
			dummyEntity.PlayEffect(m_fxNameHit);
		}

		return true;
	}

	latent function HitFxName(optional customActionType : ENR_MagicAction) : name {
		var color : ENR_MagicColor;
		if (customActionType != ENR_Unknown)
			color = NR_GetActionColor(customActionType);
		else
			color = NR_GetActionColor();

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
			color = NR_GetActionColor();
		
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

state Active in NR_MagicSpecialLightningFall {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Active: OnEnterState: " + this);
		startTime = theGame.GetEngineTimeAsSeconds();
		parent.inPostState = true;
		RunWait();
	}

	entry function RunWait() {
		var i : int;
	
		Sleep(0.5f);
		while (parent.s_lifetime > 0.f) {
			parent.s_lifetime -= parent.s_interval;
			Sleep(parent.s_interval);
			NR_Debug("Active: ShootLightning, s_lifetime = " + parent.s_lifetime);
			for (i = 1; i <= parent.s_lightningNum; i += 1) {
				parent.ShootLightning(/*cursed*/ false, thePlayer.GetWorldPosition());
				SleepOneFrame();
			}
		}
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Active: OnLeaveState: " + this);
	}
}

state Cursed in NR_MagicSpecialLightningFall {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Cursed: OnEnterState: " + this);
		parent.inPostState = true;
		Curse();
	}

	entry function Curse() {
		var playerPosition : Vector;
		var i : int;
		var cursedInterval : float;
		
		Sleep(2.f);
		parent.s_lifetime = 2.f;
		cursedInterval = parent.s_interval * 4.f;

		while (parent.s_lifetime > 0.f) {
			parent.s_lifetime -= cursedInterval;
			// shoot at player pos from past
			playerPosition = thePlayer.GetWorldPosition();
			Sleep(cursedInterval);
			parent.ShootLightning(/*cursed*/ true, playerPosition);
			//for (i = 1; i <= parent.s_lightningNum; i += 1) {
			//	parent.ShootLightning(/*cursed*/ true, playerPosition);
			//	SleepOneFrame();
			//}
		}
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Cursed: OnLeaveState: " + this);
	}
}

state Stop in NR_MagicSpecialLightningFall {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Stop: OnEnterState: " + this);
		RequestWeatherChangeTo(parent.savedWeather, 2.f, false);
		thePlayer.UnblockAction( EIAB_Movement, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Jump, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Roll, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Dodge, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Fists, 'TryPeformLongMagicAttack' );
		thePlayer.UnblockAction( EIAB_Signs, 'TryPeformLongMagicAttack' );

		parent.inPostState = false;
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Stop: OnLeaveState: " + this);
		// can be removed from cached/cursed actions TODO CHECK
		parent.inPostState = false;
	}
}
