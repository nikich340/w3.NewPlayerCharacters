abstract statemachine class NR_MagicSpecialAction extends NR_MagicAction {
	var s_lifetime 		: float;
	var s_curseChance 	: int;

	latent function OnPrepare() : bool {
		var ret : bool;
		ret = super.OnPrepare();
		// load data from map
		s_curseChance = map[ST_Universal].getI("curse_prob_" + ENR_MAToName(actionType), 20);
		NR_Debug("GenericSpecial: s_curseChance (" + ENR_MAToName(actionType) + ") = " + s_curseChance);
		s_lifetime = map[ST_Universal].getF("duration_" + ENR_MAToName(actionType), 10.f);
		if (actionType == ENR_SpecialLightningFall || actionType == ENR_SpecialMeteorFall)
			s_lifetime *= SkillDurationMultiplier(true);
		else
			s_lifetime *= SkillDurationMultiplier(false);
		return ret;
	}
	/* -> Stop/Curse */
	latent function StopAction() {
		NR_Debug("StopAction: GenericSpecial: isCursed = " + isCursed + ", s_curseChance = " + s_curseChance);
		if ( !isCursed && s_curseChance >= NR_GetRandomGenerator().nextRange(1, 100) ) {
			NR_Debug("GenericSpecial: Cursed!");
			GetWitcherPlayer().DisplayHudMessage(GetLocStringById(2115940159) + ENR_MAToLocString(actionType));
			isCursed = true;
			GotoState('Cursed');
		} else {
			NR_Debug("GenericSpecial: Stop!");
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
