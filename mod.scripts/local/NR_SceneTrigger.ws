class NR_SceneTrigger extends W3MonsterClue
{
    protected var inUse         : Bool;
    editable var playerPos      : Vector;
    editable var playerRot      : EulerAngles;
    editable var sceneMale      : CStoryScene;
    editable var sceneFemale    : CStoryScene;

    event OnInteraction( actionName : string, activator : CEntity  )
    {
        super.OnInteraction(actionName, activator);

    	NRD("OnInteraction action = " + actionName);
        if ( activator == thePlayer && actionName == "Use" && !inUse ) {
            inUse = true;
            // start fading out
            theGame.FadeOutAsync(interactionAnimTime);
            theGame.SetFadeLock( "NR_FadeOutScene" );
        	AddTimer( 'TimerFixLocation', interactionAnimTime, false );
            AddTimer( 'TimerPlayScene', interactionAnimTime + 0.2f, false );
        }
        return true;
    }

    timer function TimerFixLocation( td : float , id : int) {
        NRD("Old pos: " + VecToString(thePlayer.GetWorldPosition()));
        thePlayer.TeleportWithRotation(playerPos, playerRot);
        theGame.ResetFadeLock( "NR_FadeOutScene" );
        // correct player position to match defined "anchor"
        NRD("New pos: " + VecToString(thePlayer.GetWorldPosition()));
    }

    timer function TimerPlayScene( td : float , id : int) {
        NRD("New2 pos: " + VecToString(thePlayer.GetWorldPosition()));
        if (NR_GetPlayerManager().IsFemale())
            theGame.GetStorySceneSystem().PlayScene(sceneFemale, "Input");
        else
            theGame.GetStorySceneSystem().PlayScene(sceneMale, "Input");
        inUse = false;
    }
}
