// --- CR4Game ---
@addField(CR4Game) 
saved var nr_playerManager : NR_PlayerManager;

@wrapMethod(CR4Game)
function OnGameLoadInitFinishedSuccess()
{
	wrappedMethod();
	NR_ErasePlayerManager(theGame, "OnGameLoadInitFinishedSuccess");
}

@wrapMethod(CR4Game)
function OnGameStarted(restored : bool)
{
	wrappedMethod(restored);
	NR_OnGameStarted();
}


// --- CR4IngameMenu ---
@wrapMethod(CR4IngameMenu)
function StartNewGame()
{
	NR_ErasePlayerManager(theGame, "StartNewGame");
	wrappedMethod();
}


// --- CR4InventoryMenu ---
@wrapMethod(CR4InventoryMenu)
function OnClosingMenu()
{
	wrappedMethod();
	if ( NR_GetPlayerManager().IsReplacerActive() ) {
		NR_GetPlayerManager().UnmountEquipment();
	}
}

@wrapMethod(CR4InventoryMenu)
function OnEquipItem( item : SItemUniqueId, slot : int, quantity : int )
{
	if ( NR_GetWitcherReplacer() && NR_GetWitcherReplacer().NR_IsSlotDenied(slot) ) {
		showNotification( "<font color='#00008B'>(" + GetLocStringById(NR_GetWitcherReplacer().GetNameID()) + ")</font> " + GetLocStringById(2115940100) + SlotEnumToName(slot) );
		OnPlaySoundEvent("gui_global_denied");
		return false;
	}
	wrappedMethod(item, slot, quantity);
}
