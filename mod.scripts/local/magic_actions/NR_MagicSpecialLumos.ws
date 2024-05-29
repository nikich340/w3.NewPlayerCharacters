class NR_MagicSpecialLumos extends NR_MagicSpecialAction {
	var isActive 			: bool;
	
	default isActive 		= false;
	default isDamaging 		= false;
	default actionType 		= ENR_SpecialLumos;
	default actionSubtype = ENR_SpecialAbstractAlt;
	default performsToLevelup = 1;
	default maxLevelup 		  = 1; // action-specific
	
	latent function OnInit() : bool {
		sceneInputs.PushBack(1);
		sceneInputs.PushBack(2);
		super.OnInit();

		return true;
	}
	/*latent function OnPrepare() : bool {
		super.OnPrepare();

		return OnPrepared(true);
	}*/

	public function IsActive() : bool {
		return isActive;
	}

	public function SetActive(active : bool) {
		isActive = active;
		// for gamesave
		NR_GetReplacerSorceress().SetLumosActive(active, m_fxNameMain);
	}

	/* Non-latent version */
	public function OnPrepareSync() {
		m_fxNameMain = LumosFxName();
		NR_Debug("NR_MagicSpecialLumos:OnPrepareSync, m_fxNameMain = " + m_fxNameMain);
		inPostState = true; // prevent action erasing
		isPrepared = true;
	}

	/* Non-latent version */
	public function OnSwitchSync(enable : bool, optional fxName : name) : bool {
		NR_Debug("NR_MagicSpecialLumos:OnSwitchSync, isActive = " + isActive);

		OnPrepareSync();
		if ( IsNameValid(fxName) )
			m_fxNameMain = fxName;

		if (enable) {
			if (!IsActive()) {
				NR_GetReplacerSorceress().PlayEffect( m_fxNameMain );
				GotoState('Active');
			}
		}
		if (!enable) {
			if (IsActive()) {
				NR_GetReplacerSorceress().StopEffect( m_fxNameMain );
				GotoState('Stop');
			}
		}
		SetActive(enable);
		NR_Debug("NR_MagicSpecialLumos:OnSwitchSync = [" + m_fxNameMain + "] " + enable);

		return true;
	}

	latent function OnPerform() : bool {
		if (IsInSetupScene() && !IsActive()) {
			OnSwitchSync(true);
			Sleep(2.5f);
			OnSwitchSync(false);
			return OnPerformed( true );
		}

		return OnPerformed( OnSwitchSync(!IsActive()) );
	}

	/* Non-latent version */
	function BreakActionSync() {
		if (isPerformed)
			return;
	}

	latent function BreakAction() {
		BreakActionSync();
	}

	function LumosFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'lumos_yellow';
			case ENR_ColorOrange:
				return 'lumos_orange';
			case ENR_ColorRed:
				return 'lumos_red';
			case ENR_ColorPink:
				return 'lumos_pink';
			case ENR_ColorViolet:
				return 'lumos_violet';
			case ENR_ColorBlue:
				return 'lumos_blue';
			case ENR_ColorSeagreen:
				return 'lumos_seagreen';
			case ENR_ColorGreen:
				return 'lumos_green';
			case ENR_ColorSpecial1:
				return 'lumos_special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'lumos_white';
		}
	}
}

state Active in NR_MagicSpecialLumos {
	var lightenedEntities : array<CGameplayEntity>;

	event OnEnterState( prevStateName : name )
	{
		ActiveLoop();		
	}

	entry function ActiveLoop() {
		var i : int;
		var comp : CGameplayLightComponent;
		var entities : array<CGameplayEntity>;

		while (true) {
			Sleep(0.1f);

			if ( !parent.IsActionAbilityEnabled("AutoLighten") ) {
				NR_Debug("AutoLighten is disabled");
				DisableAllLightened();
				continue;
			}

			entities.Clear();
			FindGameplayEntitiesInRange( entities, thePlayer, 20.f, 999 );
			NR_Debug("AutoLighten: check " + entities.Size());
			for (i = 0; i < entities.Size(); i += 1) {
				if (lightenedEntities.Contains(entities[i]))
					continue;
				comp = (CGameplayLightComponent)entities[i].GetComponentByClassName('CGameplayLightComponent');
				NR_Debug("AutoLighten: check entity: " + comp);
				if (comp && !comp.IsLightOn()/* && !comp.factOnIgnite*/) {
					comp.SetFadeLight(true);
					lightenedEntities.PushBack(entities[i]);
					NR_Debug("AutoLighten: lighten " + entities[i]);
				}
			}
		}
	}

	protected function DisableAllLightened() {
		var i : int;
		var comp : CGameplayLightComponent;

		for (i = lightenedEntities.Size() - 1; i >= 0; i -= 1) {
			comp = (CGameplayLightComponent)lightenedEntities[i].GetComponentByClassName('CGameplayLightComponent');
			if (comp && comp.IsLightOn()) {
				comp.SetFadeLight(false);
			}
			NR_Debug("AutoLighten: disable " + lightenedEntities[i]);
			lightenedEntities.PopBack();
		}
	}

	event OnLeaveState( nextStateName : name )
	{
		DisableAllLightened();
	}
}
