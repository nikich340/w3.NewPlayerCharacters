class NR_MagicSpecialLumos extends NR_MagicSpecialAction {
	var isActive 			: bool;
	
	default isActive 		= false;
	default actionType 		= ENR_SpecialLumos;
	default actionSubtype = ENR_SpecialAbstractAlt;
	
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
			}
		}
		if (!enable) {
			if (IsActive()) {
				NR_GetReplacerSorceress().StopEffect( m_fxNameMain );
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

/*
state RunWait in NR_MagicSpecialLumos {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		NR_Debug("RunWait: OnEnterState: " + this);
		RunWait();		
	}
	entry function RunWait() {
		NR_GetReplacerSorceress().SetLumosActive(true);
		parent.isActive = true;
		Sleep( parent.s_lifetime );
		NR_Debug("RunWait: Stop lumos!");
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("RunWait: OnLeaveState: " + this);
		parent.inPostState = false;
	}
}
state Stop in NR_MagicSpecialLumos {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		NR_Debug("Stop: OnEnterState: " + this);
		Stop();
		parent.inPostState = false;
	}
	entry function Stop() {
		NR_GetReplacerSorceress().SetLumosActive(false);
		parent.isActive = false;
		NR_GetReplacerSorceress().StopEffect( parent.m_fxNameMain );
	}
	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("Stop: OnLeaveState: " + this);
		// can be removed from cached/cursed actions
	}
}
state Curse in NR_MagicSpecialLumos {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("Curse: OnEnterState: " + this);
		Curse();
	}
	entry function Curse() {
		// do nothing
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("OnLeaveState: " + this);
	}
}
*/
