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
