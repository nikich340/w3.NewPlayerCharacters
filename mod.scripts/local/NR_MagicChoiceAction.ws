class NR_MagicChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var str_id_1 : int;
	editable var str_id_2 : int;
	editable var str_id_3 : int;
	editable var separator : string;
	editable var prefix : string;
	editable var suffix : string;

	function GetActionText() : string			
	{
		var text : String;

		text = prefix + GetLocStringById(str_id_1);
		if (str_id_2) {
			text += separator + GetLocStringById(str_id_2);
		}
		if (str_id_3) {
			text += separator + GetLocStringById(str_id_3);
		}
		text += suffix;
		return text;
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		return DialogAction_BRIBE;
	}
}
