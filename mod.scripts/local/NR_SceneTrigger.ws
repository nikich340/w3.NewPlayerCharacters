class NR_SceneTrigger extends W3MonsterClue
{
    editable var scene : CStoryScene;

    event OnInteraction( actionName : string, activator : CEntity  )
    {
    	NRD("OnInteraction action = " + actionName);
        if ( activator == thePlayer && actionName == "Use" ) {
        	NRD("scene = " + scene);
        }
    }
}
