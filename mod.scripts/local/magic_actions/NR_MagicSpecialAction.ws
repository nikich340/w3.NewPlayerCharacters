abstract statemachine class NR_MagicSpecialAction extends NR_MagicAction {
	var s_specialLifetime 		: int;
	var s_specialCurseProb 		: int;

	latent function OnPrepare() : bool {
		var ret : bool;
		ret = super.OnPrepare();
		// load data from map
		s_specialCurseProb = map[ST_Universal].getI("s_specialCurseProb", 50);
		NRD("GenericSpecial: s_specialCurseProb = " + s_specialCurseProb);
		/* s_specialLifetime = set in action class! */

		return ret;
	}
	/* -> Stop/Curse */
	latent function StopAction() {
		NRD("GenericSpecial: isCursed = " + isCursed + ", s_specialCurseProb = " + s_specialCurseProb);
		if ( !isCursed && s_specialCurseProb >= RandRange(100) + 1 ) {
			NR_Notify("GenericSpecial: Cursed!");
			isCursed = true;
			GotoState('Cursed');
		} else {
			NRD("GenericSpecial: Stop!");
			GotoState('Stop');
		}
	}
}
/*
state RunWait in NR_MagicSpecialAction {
	event OnEnterState( prevStateName : name )
	{		
	}
	event OnLeaveState( nextStateName : name )
	{		
	}
}
state Stop in NR_MagicSpecialAction {
	event OnEnterState( prevStateName : name )
	{		
	}
	event OnLeaveState( nextStateName : name )
	{		
	}
}
state Curse in NR_MagicSpecialAction {
	event OnEnterState( prevStateName : name )
	{		
	}
	event OnLeaveState( nextStateName : name )
	{
	}
}
*/
