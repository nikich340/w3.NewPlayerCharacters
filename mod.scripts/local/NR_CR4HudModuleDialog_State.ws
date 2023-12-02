state NR_ScenePreviewAppearance_DialogState in CR4HudModuleDialog {
	event OnEnterState( prevStateName : name )
    {
        theInput.RegisterListener( this, 'OnBack', 'EnablePhotoMode' );
        NR_GetPlayerManager().SetCanShowAppearanceInfo(true);
    }

    event OnBack( action : SInputAction )
    {
        /*var i : int;
        NR_Debug("OnBack: IsPressed = " + IsPressed(action) + ", IsReleased = " + IsReleased(action));
        for (i = 0; i < parent.lastSetChoices.Size(); i += 1) {
            NR_Debug("CHOICE[" + i + "] = " + parent.lastSetChoices[i].description);
        }*/
        if ( IsReleased( action ) ) {
            OnDialogOptionSelected(0);
            OnDialogOptionAccepted(0);
        }
    }
    
    event OnDialogOptionSelected( index : int )
    {
        // NR_Notify("OnDialogOptionSelected: " + parent.lastSetChoices[index].description);
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
        theInput.UnregisterListener( this, 'EnablePhotoMode' );
        NR_GetPlayerManager().SetCanShowAppearanceInfo(false);
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
        dialogModule.GotoState('NR_SceneDefault_DialogState');
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