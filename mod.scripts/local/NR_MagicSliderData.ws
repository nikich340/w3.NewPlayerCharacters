class NR_MagicSliderData extends DialogueSliderData
{
	public var signName : name;
	public var varName : String;
	protected var isCompleted : bool;

	public /* override */ function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		l_flashObject = super.GetGFxData(parentFlashValueStorage);
		l_flashObject.SetMemberFlashInt("playerMoney", 100);	
		l_flashObject.SetMemberFlashBool("displayMoneyIcon", false);		
		return l_flashObject;
	}

	public function IsCompleted() : bool {
		return isCompleted;
	}

	public function /* override */ OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "enter-gamepad_A")
		{
			// invalid value
			if ( currentValue > 100 )
			{
				theGame.GetGuiManager().ShowNotification( GetLocStringById(1223566) );
				return;
			}
			
			NR_GetMagicManager().SetParamInt(signName, varName, currentValue);
			isCompleted = true;
			// ClosePopup();
		}
	}
}
