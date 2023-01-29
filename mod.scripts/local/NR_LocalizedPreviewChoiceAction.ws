class NR_LocalizedPreviewChoiceAction extends CStorySceneChoiceLineActionScripted
{
	editable var prefix_id : int;
	editable var appearance_name : name;
	editable var coloring_index : int;
	editable var variants : int;

	function GetActionText() : string			
	{
		var text : String;

		text = "(" + GetLocStringById(prefix_id) + ") " + NameToString(appearance_name);
		if (coloring_index > 0) {
			text += " " + GetLocStringById(2115940102) + " #" + IntToString(coloring_index);
		}
		if (variants > 0) {
			text += " [" + IntToString(variants) + " " + GetLocStringById(2115940116) + "]";
		}
		return text;
	}
	
	function GetActionIcon() : EDialogActionIcon 	
	{ 
		return DialogAction_BRIBE;
	}
}