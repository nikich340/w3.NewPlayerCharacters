class NR_MagicSpecialLumos extends NR_MagicSpecialAction {
	var isActive 			: bool;
	
	default isActive 		= false;
	default actionType 		= ENR_SpecialLumos;
	default actionSubtype = ENR_SpecialAbstractAlt;
	
	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 100);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			sceneInputs.PushBack(1);
			sceneInputs.PushBack(2);
			PlayScene( sceneInputs );
		}

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
	}

	/* Non-latent version */
	public function OnPrepareSync() {
		m_fxNameMain = LumosFxName();
		inPostState = true; // prevent action erasing
		isPrepared = true;
	}

	/* Non-latent version */
	public function OnSwitchSync(enable : bool) : bool {
		NRD("NR_MagicSpecialLumos:OnSwitchSync, isActive = " + isActive);

		if (!isPrepared) {
			OnPrepareSync();
		}

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
		NRD("NR_MagicSpecialLumos:OnSwitchSync = " + enable);

		return true;
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
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
		var color : ENR_MagicColor = NR_GetActionColor(ENR_SpecialAbstractAlt);

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
			//case ENR_ColorSpecial1:
			//	return 'special1';
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
		NRD("RunWait: OnEnterState: " + this);
		RunWait();		
	}
	entry function RunWait() {
		NR_GetReplacerSorceress().SetLumosActive(true);
		parent.isActive = true;
		Sleep( parent.s_lifetime );
		NRD("RunWait: Stop lumos!");
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("RunWait: OnLeaveState: " + this);
		parent.inPostState = false;
	}
}
state Stop in NR_MagicSpecialLumos {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		NRD("Stop: OnEnterState: " + this);
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
		NRD("Stop: OnLeaveState: " + this);
		// can be removed from cached/cursed actions
	}
}
state Curse in NR_MagicSpecialLumos {
	event OnEnterState( prevStateName : name )
	{
		NRD("Curse: OnEnterState: " + this);
		Curse();
	}
	entry function Curse() {
		// do nothing
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}
*/
