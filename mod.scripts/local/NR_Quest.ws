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