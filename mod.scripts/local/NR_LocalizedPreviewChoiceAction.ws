class NR_LocalizedPreviewChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var prefix_id : int;
	editable var appearance_name : String;
	editable var coloring_index : int;

	function GetActionText() : string			
	{
		var text : String;

		text = "(" + GetLocStringById(prefix_id) + ") " + appearance_name;
		if (coloring_index > 0) {
			text += " " + GetLocStringById(2115940102) + " #" + IntToString(coloring_index);
		}
		return text;
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		return DialogAction_BRIBE;
	}
}