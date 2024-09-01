/* replace "{loc_id}" entries into actual localized string, and "{ }" into "&nbsp;" */
// example: "I{ }like {0000300169}." -> "I&nbsp;like Philippa Eilhart."
function NR_FormatLocString(str : String) : String {
	var     i, id : int;
	var c, result : String;
	var   temp_id : String;
	var   read_id : bool;

	for (i = 0; i < StrLen(str); i += 1) {
		c = StrMid(str, i, 1);
		if (read_id) {
			if (c == "}") {
				if (temp_id == " ") {
					result += "&nbsp;";
				} else {
					id = StringToInt(temp_id, -1);
					if (id > 0) {
						result += GetLocStringById(id);
					} else {
						result += "{" + temp_id + "}";
					}
				}
				read_id = false;
				temp_id = "";
			} else {
				temp_id += c;
			}
		} else {
			if (c == "{") {
				read_id = true;
			} else {
				result += c;
			}
		}
	}
	if (temp_id != "") {
		result += "{" + temp_id;
	}

	return result;
}

class NR_FormattedLocChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var str : String;

	function CanUseAction() : bool {
		return true;
	}

	function GetActionText() : string			
	{
		return NR_FormatLocString(str);
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		return DialogAction_NONE;
	}
}

class NR_FormattedMagicChoiceAction extends NR_FormattedLocChoiceAction
{
	editable var type : name;
	editable var unlockIfLearned : bool;
	editable var unlockIfLearning : bool;
	editable var abilityName : String;
	editable var dlcName : name;

	function CanUseAction() : bool {
		var enumType : ENR_MagicAction;
		var unlocked : bool;

		if ( IsNameValid(type) ) {
			enumType = ENR_NameToMA(type);
			unlocked = false;
			if ( unlockIfLearning ) {
				if ( NR_GetMagicManager().IsActionLearning(enumType) )
					unlocked = true;
			}
			if ( unlockIfLearned ) {
				if ( NR_GetMagicManager().IsActionLearned(enumType) )
					unlocked = true;
			}
			if ( !unlocked && !NR_GetMagicManager().IsActionCustomizationUnlocked(enumType) )
				return false;
		}

		if ( StrLen(abilityName) > 0 && !NR_GetMagicManager().IsActionAbilityUnlocked(enumType, abilityName) )
			return false;

		if ( IsNameValid(dlcName) && !theGame.GetDLCManager().IsDLCAvailable(dlcName) )
			return false;

		return true;
	}

	function GetActionText() : string			
	{
		var text : String;

		text = super.GetActionText();
		if ( !CanUseAction() ) {
			// [locked] prefix: String
			text = "[" + GetLocStringById(1066070) + "] " + text;
		}
		return text;
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		return DialogAction_NONE;
	}
}

class NR_SwitchableAbilityMagicChoiceAction extends NR_FormattedLocChoiceAction
{
	editable var type : name;
	editable var abilityName : String;
	editable var abilityStrId : int;

	function CanUseAction() : bool {
		var enumType : ENR_MagicAction;

		enumType = ENR_NameToMA(type);
		if ( StrLen(abilityName) > 0 && NR_GetMagicManager().IsActionAbilityUnlocked(enumType, abilityName) )
			return true;

		return false;
	}

	function GetActionText() : string			
	{
		var text : String;
		var enumType : ENR_MagicAction;

		enumType = ENR_NameToMA(type);
		text = ENR_MAToLocString(enumType) + ": " + NR_GetLocStringByIdExt(abilityStrId) + ": ";
		if ( !CanUseAction() ) {
			// [locked]
			text += "[" + GetLocStringById(1066070) + "]";
		} else {
			if (NR_GetMagicManager().IsActionAbilityDisabledByUser(enumType, abilityName)) {
				// disabled
				text += NR_GetLocStringByIdExt(2115940087);
			} else {
				// enabled
				text += NR_GetLocStringByIdExt(2115940086);
			}
		}
		return text;
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		return DialogAction_NONE;
	}
}

class NR_SwitchableOnPlayerTypeChoiceAction extends NR_FormattedLocChoiceAction {
	editable var checkFact : bool;
	editable var checkFactInverted : bool;
	editable var factPrefix : String; // factPrefix + NR_GetPlayerManager().GetCurrentPlayerType()
	
	editable var enabledStringId : int; // "enabled" 2115940086, "visible" 2115940521
	editable var disabledStringId : int; // "disabled" 2115940087, "invisible" 2115940520
	editable var allowedForVanilla : bool;

	function CanUseAction() : bool {
		if (!allowedForVanilla && !NR_GetPlayerManager().IsReplacerActive())
			return false;

		return true;
	}

	function GetActionText() : string			
	{
		var text : String;

		text = super.GetActionText();
		if ( !CanUseAction() ) {
			// [locked]
			text += "[" + GetLocStringById(1066070) + "]";
		} else {
			if ( checkFact ) {
				if ( FactsDoesExist(factPrefix + NR_GetPlayerManager().GetCurrentPlayerType()) ) {
					// enabled
					text += NR_GetLocStringByIdExt(enabledStringId);
				} else {
					// disabled
					text += NR_GetLocStringByIdExt(disabledStringId);
				}
			} else if ( checkFactInverted ) {
				if ( FactsDoesExist(factPrefix + NR_GetPlayerManager().GetCurrentPlayerType()) ) {
					// disabled
					text += NR_GetLocStringByIdExt(disabledStringId);
				} else {
					// enabled
					text += NR_GetLocStringByIdExt(enabledStringId);
				}
			}
		}
		return text;
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		return DialogAction_NONE;
	}
}

