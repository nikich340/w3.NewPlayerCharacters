state NR_ScenePreviewAppearance_DialogState in CR4HudModuleDialog {
	event OnEnterState( prevStateName : name )
    {
    }
    
    event OnDialogOptionSelected( index : int )
    {
        parent.OnDialogOptionSelected( index );
        NR_GetPlayerManager().OnDialogOptionSelected(index);
    }
    
    event OnDialogOptionAccepted( index : int )
    {
        parent.OnDialogOptionAccepted( index );
        NR_GetPlayerManager().OnDialogOptionAccepted(index);
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

function NR_EnterScenePreviewState(stateName : name)
{
    var hud : CR4ScriptedHud;
    var dialogModule : CR4HudModuleDialog;
    
    hud = (CR4ScriptedHud)theGame.GetHud();
    
    if (hud)
    {
        dialogModule = hud.GetDialogModule();
        dialogModule.GotoState(stateName);
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
        dialogModule.GotoState('NR_EnterScenePreviewState');
    }
}

storyscene function NR_EnterScenePreviewState_S(player: CStoryScenePlayer, stateName : name) {
	NR_EnterScenePreviewState(stateName);
    NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_ExitScenePreviewState_S(player: CStoryScenePlayer) {
	NR_ExitScenePreviewState();
    NR_GetPlayerManager().HideAppearanceInfo();
}