class NR_MagicSpecialLumos extends NR_MagicSpecialAction {
	var isActive 			: bool;
	default isActive 		= false;
	default actionType 		= ENR_SpecialLumos;
	
	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 40);
		NRD("phraseChance = " + phraseChance);
		if ( phraseChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			phraseInputs.PushBack(1);
			phraseInputs.PushBack(2);
			PlayScene( phraseInputs );
		}

		return true;
	}
	/*latent function OnPrepare() : bool {
		super.OnPrepare();

		return OnPrepared(true);
	}*/
	/* Non-latent version */
	public function OnPerformSync() : bool {
		if (isActive) {
			BreakActionSync();
			return true;
		}

		s_specialLifetime = map[ST_Universal].getI("s_controlLifetime", 60);
		if ( FactsDoesExist("nr_lumos_fx") )
			effectColor = FactsQuerySum("nr_lumos_fx");

		if ( map[ST_Quen].hasKey("lumos_color_" + IntToString(effectColor)) ) {
			NR_GetReplacerSorceress().PlayEffect( map[ST_Quen].getN("lumos_color_" + IntToString(effectColor)) );
		} else {
			return false;
		}
		GotoState('RunWait');
		return true;
	}
	latent function OnPerform() : bool {
		return OnPerformed( OnPerformSync() );
	}
	/* Non-latent version */
	public function BreakActionSync() {
		GotoState('Stop');
	}
	latent function BreakAction() {
		BreakActionSync();
	}
}

state RunWait in NR_MagicSpecialLumos {
	event OnEnterState( prevStateName : name )
	{
		NRD("RunWait: OnEnterState: " + this);
		RunWait();		
	}
	entry function RunWait() {
		NR_GetReplacerSorceress().SetLumosActive(true);
		parent.isActive = true;
		Sleep( parent.s_specialLifetime );
		NRD("RunWait: Stop lumos!");
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("RunWait: OnLeaveState: " + this);
	}
}
state Stop in NR_MagicSpecialLumos {
	event OnEnterState( prevStateName : name )
	{
		NRD("Stop: OnEnterState: " + this);
		Stop();
	}
	entry function Stop() {
		/*for (i = 0; i <= EnumGetMax('ENR_MagicColor'); i += 1) {
			if ( map[ST_Quen].hasKey("lumos_color_" + IntToString(i)) )
				NR_GetReplacerSorceress().StopEffect( map[ST_Quen].getN("lumos_color_" + IntToString(i)) );
		}*/
		NR_GetReplacerSorceress().SetLumosActive(false);
		parent.isActive = false;
		NR_GetReplacerSorceress().StopEffect( parent.map[ST_Quen].getN("lumos_color_" + IntToString(parent.effectColor)) );
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
		// TODO ?
		// do nothing atm
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}
