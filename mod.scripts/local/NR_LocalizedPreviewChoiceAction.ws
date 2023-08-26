class NR_LocalizedPreviewChoiceAction extends CStorySceneChoiceLineActionScripted
{
	// if custom dlc
	editable var dlc_id : name;
	editable var dlc_name_key : String;
	editable var dlc_name_str : String;

	editable var prefix_id : int;
	editable var prefix_name_key : String;
	editable var extra_name_key : name;

	editable var index : int;
	editable var equip_variant : int;
	editable var variants : int;

	function CanUseAction() : bool {
		if ( IsNameValid(dlc_id) )
			return NR_GetPlayerManager().NR_IsDLCInstalled( dlc_id );
		else
			return true;
	}

	function GetActionText() : String			
	{
		var text : String;
		var extra_name_key_str : String;

		text = "";
		if (StrLen(dlc_name_key) > 0 && NR_IsLocStrExists(dlc_name_key)) {
			text += "[" + NR_GetLocStringByKeyExt(dlc_name_key) + "]";
		} else if (StrLen(dlc_name_str) > 0) {
			text += "[" + dlc_name_str + "]";
		}

		if (prefix_id > 0) {
			text += "(" + GetLocStringById(prefix_id) + ")";
		} else if (StrLen(prefix_name_key) > 0) {
			text += "(" + NR_GetLocStringByKeyExt(prefix_name_key) + ")";
		}

		if ( IsNameValid(extra_name_key) ) {
			extra_name_key_str = NameToString(extra_name_key);
			if ( NR_IsLocStrExists(extra_name_key) )
				text += " " + GetLocStringByKey(extra_name_key_str);
			else
				text += " " + extra_name_key_str;
		}

		if (equip_variant > 0) {
			text += " v" + IntToString(equip_variant);
		}

		if (index > 0) {
			text += " #" + IntToString(index);
		}

		if (variants > 0) {
			text += " [" + IntToString(variants) + " " + GetLocStringById(2115940116) + "]";
		}
		return text;
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		return DialogAction_NONE; // [0-30]
	}
}

function NR_IsLocStrExists(strLocKey : String) : bool
{
	return StrLen(GetLocStringByKey(strLocKey)) > 0;
}

function NR_GetLocStringByKeyExt(strLocKey : String) : String
{
	if (NR_IsLocStrExists(strLocKey))
		return GetLocStringByKey(strLocKey);
	else
		return "#" + strLocKey;
}

function NR_IsIdStrExists(strId : int) : bool
{
	return StrLen(GetLocStringById(strId)) > 0;
}

function NR_GetLocStringByIdExt(strId : int) : String
{
	if (NR_IsIdStrExists(strId))
		return GetLocStringById(strId);
	else
		return "#" + strId;
}
