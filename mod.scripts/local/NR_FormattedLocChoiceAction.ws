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
	editable var dlcName : name;

	function CanUseAction() : bool {
		if ( IsNameValid(dlcName) && !theGame.GetDLCManager().IsDLCAvailable(dlcName) )
			return false;

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

class NR_FormattedMagicChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var str : String;
	editable var type : name;
	editable var abilityName : String;
	editable var dlcName : name;

	function CanUseAction() : bool {
		var enumType : ENR_MagicAction;

		enumType = ENR_NameToMA(type);
		if ( !NR_GetMagicManager().IsActionCustomizationUnlocked(enumType) )
			return false;

		if ( StrLen(abilityName) > 0 && !NR_GetMagicManager().IsActionAbilityUnlocked(enumType, abilityName) )
			return false;

		if ( IsNameValid(dlcName) && !theGame.GetDLCManager().IsDLCAvailable(dlcName) )
			return false;

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
