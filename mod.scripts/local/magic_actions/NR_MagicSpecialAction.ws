abstract statemachine class NR_MagicSpecialAction extends NR_MagicAction {
	var s_lifetime 		: float;
	var s_curseChance 	: int;
	var su_oneliner 	: SU_OnelinerEntity;
	var su_manager		: SUOL_Manager;

	default performsToLevelup = 25; // action-specific

	latent function OnPrepare() : bool {
		var ret : bool;
		ret = super.OnPrepare();
		// load data from map
		su_manager = SUOL_getManager();
		s_curseChance = map[ST_Universal].getI("curse_chance_" + ENR_MAToName(actionType), 15);
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
		NR_Debug(actionType + ".StopAction: isCursed = " + isCursed + ", s_curseChance = " + s_curseChance);
		if ( !isCursed && !IsInSetupScene() && s_curseChance >= NR_GetRandomGenerator().nextRange(1, 100) ) {
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

state Active in NR_MagicSpecialAction {
	protected var startTime : float;
	protected var onelinerText : String;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	latent function UpdateOnelinerTime(optional textSize : int, optional textHexColor : String, optional oneliner : SU_OnelinerEntity) {
		var text : String;

		if (textSize < 1) {
			textSize = 30;
		}
		if (StrLen(textHexColor) < 7) {
			textHexColor = "#2EFF19";
		}
		if (!oneliner) {
			oneliner = parent.su_oneliner;
		}
		text = (new SUOL_TagBuilder in thePlayer)
    		.tag("font")
    		.attr("size", IntToString(textSize))
    		.attr("color", textHexColor)
    		.text( CeilF(parent.s_lifetime - GetLocalTime()) );
    	if (text != onelinerText) {
    		oneliner.setText( text );
    		parent.su_manager.updateOneliner(oneliner);
    		onelinerText = text;
    	}
	}

	event OnEnterState( prevStateName : name )
	{
		NR_Debug(parent.actionType + "::Active.OnEnterState.");
		startTime = theGame.GetEngineTimeAsSeconds();
		parent.inPostState = true;
		ActiveLoop();	
	}

	entry function ActiveLoop() {}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug(parent.actionType + "::Active: OnLeaveState.");
	}
}

state Cursed in NR_MagicSpecialAction {
	protected var startTime : float;
	protected var onelinerText : String;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	latent function UpdateOnelinerTime(optional textSize : int, optional textHexColor : String, optional oneliner : SU_OnelinerEntity) {
		var text : String;

		if (textSize < 1) {
			textSize = 30;
		}
		if (StrLen(textHexColor) < 7) {
			textHexColor = "#FF0000";
		}
		if (!oneliner) {
			oneliner = parent.su_oneliner;
		}
		text = (new SUOL_TagBuilder in thePlayer)
    		.tag("font")
    		.attr("size", IntToString(textSize))
    		.attr("color", textHexColor)
    		.text( CeilF(parent.s_lifetime - GetLocalTime()) );
    	if (text != onelinerText) {
    		oneliner.setText( text );
    		parent.su_manager.updateOneliner(oneliner);
    		onelinerText = text;
    	}
	}

	event OnEnterState( prevStateName : name )
	{
		startTime = theGame.GetEngineTimeAsSeconds();
		NR_Debug(parent.actionType + "::Cursed: OnEnterState.");
		parent.inPostState = true;
		CursedLoop();
	}

	entry function CursedLoop() {}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug(parent.actionType + "::Cursed: OnLeaveState.");
	}
}

state Stop in NR_MagicSpecialAction {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug(parent.actionType + "::Stop: OnEnterState.");
		parent.inPostState = true;
		StopLoop();
		parent.inPostState = false;
	}

	entry function StopLoop() {}

	event OnLeaveState( nextStateName : name )
	{
		NR_Debug(parent.actionType + "::Stop: OnLeaveState.");
		parent.inPostState = true;
	}
}
