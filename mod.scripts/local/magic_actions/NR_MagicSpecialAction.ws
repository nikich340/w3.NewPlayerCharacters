abstract statemachine class NR_MagicSpecialAction extends NR_MagicAction {
	var s_lifetime 		: float;
	var s_curseChance 	: int;

	latent function OnPrepare() : bool {
		var ret : bool;
		ret = super.OnPrepare();
		// load data from map
		s_curseChance = map[ST_Universal].getI("curse_prob_" + ENR_MAToName(actionType), 20);
		NRD("GenericSpecial: s_curseChance (" + ENR_MAToName(actionType) + ") = " + s_curseChance);
		s_lifetime = map[ST_Universal].getF("duration_" + ENR_MAToName(actionType), 5.f);
		if (actionType == ENR_SpecialLightningFall || actionType == ENR_SpecialMeteorFall)
			s_lifetime *= SkillDurationMultiplier(true);
		else
			s_lifetime *= SkillDurationMultiplier(false);
		return ret;
	}
	/* -> Stop/Curse */
	latent function StopAction() {
		NRD("GenericSpecial: isCursed = " + isCursed + ", s_curseChance = " + s_curseChance);
		if ( !isCursed && RandRange(100) + 1 <= s_curseChance ) {
			NRD("GenericSpecial: Cursed!");
			GetWitcherPlayer().DisplayHudMessage(GetLocStringById(2115940159) + ENR_MAToLocString(actionType));
			isCursed = true;
			GotoState('Cursed');
		} else {
			NRD("GenericSpecial: Stop!");
			GotoState('Stop');
		}
	}
}
/*
state Active in NR_MagicSpecialAction {
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
state Stop in NR_MagicSpecialAction {
	event OnEnterState( prevStateName : name )
	{		
	}
	event OnLeaveState( nextStateName : name )
	{		
	}
}
