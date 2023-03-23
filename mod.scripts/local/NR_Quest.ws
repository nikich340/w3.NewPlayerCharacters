latent quest function NR_Wait_Q(sec : float) {
	Sleep(sec);
}

quest function NR_InitPlayerManager_Q() {
	NR_GetPlayerManager();
}

quest function NR_ChangePlayer_Q() {
	var newPlayerType 	: ENR_PlayerType;
	var nr_manager 		: NR_PlayerManager;

	nr_manager = NR_GetPlayerManager();
	if (!nr_manager)
		return;

	newPlayerType = (ENR_PlayerType)FactsQuerySum("nr_scene_player_change_type");
	NR_Notify("NR_ChangePlayer_Q: scene change to -> " + newPlayerType);
	if ( nr_manager.IsFemale() != nr_manager.IsFemaleType(newPlayerType) ) {
		nr_manager.SetDefaultAppearance(newPlayerType);
	}
	NR_ChangePlayer(newPlayerType);
	FactsRemove("nr_scene_player_change_type");	
}

quest function NR_IsPlayerFemale_Q() : bool {
	return NR_GetPlayerManager().IsFemale();
}

quest function NR_FadeOutQuestBlack( fadeTime : float ) {
	FadeOutQuest(fadeTime, Color(0, 0, 0, 0));
}

quest function NR_AddChameleonPotion() {
	thePlayer.inv.AddAnItem('nr_chameleon_potion', 1);
}

quest function NR_UseChameleonPotion() {
	var invMenu : CR4InventoryMenu;
	var rootMenu : CR4Menu;
	//invMenu = (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
	//if (invMenu)
	//	invMenu.OnCloseMenu();
	NR_Notify("NR_UseChameleonPotion");
	theGame.Unpause("menus");
    rootMenu = theGame.GetGuiManager().GetRootMenu();
    if ( rootMenu )
    {
        rootMenu.CloseMenu();
    }

	theSound.SoundEvent("gui_character_synergy_effect");
	if ( !thePlayer.IsEffectActive( 'invisible' ) )
	{
		thePlayer.PlayEffect( 'use_potion' );
	}
}