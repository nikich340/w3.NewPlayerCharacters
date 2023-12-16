state NR_ScenePreviewAppearance_DialogState in CR4HudModuleDialog {
	event OnEnterState( prevStateName : name )
    {
        theInput.RegisterListener( this, 'OnBack', 'EnablePhotoMode' );
        NR_GetPlayerManager().SetCanShowAppearanceInfo(true);
    }

    event OnBack( action : SInputAction )
    {
        if ( IsReleased( action ) ) {
            OnDialogOptionSelected(0);
            OnDialogOptionAccepted(0);
        }
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
        theInput.UnregisterListener( this, 'EnablePhotoMode' );
        NR_GetPlayerManager().SetCanShowAppearanceInfo(false);
    }
}

state NR_ScenePreviewSpells_DialogState in CR4HudModuleDialog {
    event OnEnterState( prevStateName : name )
    {
        theInput.RegisterListener( this, 'OnBack', 'EnablePhotoMode' );
    }

    event OnBack( action : SInputAction )
    {
        if ( IsReleased( action ) ) {
            parent.OnDialogOptionSelected(0);
            parent.OnDialogOptionAccepted(0);
        }
    }

    event OnLeaveState( nextStateName : name )
    {
        theInput.UnregisterListener( this, 'EnablePhotoMode' );
    }
}

state NR_SceneDefault_DialogState in CR4HudModuleDialog {
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
