class NR_SceneTrigger extends W3MonsterClue
{
    editable var scene : CStoryScene;

    event OnInteraction( actionName : string, activator : CEntity  )
    {
    	NR_Debug("OnInteraction action = " + actionName);
        if ( activator == thePlayer && actionName == "Use" ) {
        	NR_Debug("scene = " + scene);
        }
    }
}
