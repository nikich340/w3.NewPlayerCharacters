state NR_ScenePreview_DialogState in CR4HudModuleDialog {
	event OnEnterState( prevStateName : name )
    {
    }
    
    event OnDialogOptionSelected( index : int )
    {
        parent.OnDialogOptionSelected( index );
        NR_GetPlayerManager().OnDialogOptionSelected(index);
    }

    event OnLeaveState( nextStateName : name )
    {
    }
}

state NR_SceneDefault_DialogState in CR4HudModuleDialog {
    event OnEnterState( prevStateName : name )
    {
    }

    event OnLeaveState( nextStateName : name )
    {
    }
}

function NR_EnterScenePreviewState()
{
    var hud : CR4ScriptedHud;
    var dialogModule : CR4HudModuleDialog;
    
    hud = (CR4ScriptedHud)theGame.GetHud();
    
    if (hud)
    {
        dialogModule = hud.GetDialogModule();
        dialogModule.GotoState('NR_ScenePreview_DialogState');
    }
}
function NR_ExitScenePreviewState()
{
    var hud : CR4ScriptedHud;
    var dialogModule : CR4HudModuleDialog;
    
    hud = (CR4ScriptedHud)theGame.GetHud();
    
    if (hud)
    {
        dialogModule = hud.GetDialogModule();
        dialogModule.GotoState('NR_SceneDefault_DialogState');
    }
}

storyscene function NR_EnterScenePreviewState_S(player: CStoryScenePlayer){
	NR_EnterScenePreviewState();
}

storyscene function NR_ExitScenePreviewState_S(player: CStoryScenePlayer){
	NR_ExitScenePreviewState();
}