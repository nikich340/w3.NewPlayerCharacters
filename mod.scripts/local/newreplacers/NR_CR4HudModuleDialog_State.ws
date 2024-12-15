state NR_ScenePreviewAppearance_DialogState in CR4HudModuleDialog {
	event OnEnterState( prevStateName : name )
    {
        NR_GetPlayerManager().SetCanShowAppearanceInfo(true);
        Run_ScenePreviewAppearance();
    }

    entry function Run_ScenePreviewAppearance() {
        while (true) {
            SleepOneFrame();
            if ( theInput.IsActionJustReleased( 'EnablePhotoMode' ) )
                GoBack();
        }
    }

    public function GoBack()
    {
        OnDialogOptionSelected(0);
        OnDialogOptionAccepted(0);
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
        NR_GetPlayerManager().SetCanShowAppearanceInfo(false);
    }
}

state NR_ScenePreviewSpells_DialogState in CR4HudModuleDialog {
    event OnEnterState( prevStateName : name )
    {
        Run_ScenePreviewSpells();
    }

    entry function Run_ScenePreviewSpells() {
        while (true) {
            SleepOneFrame();
            if ( theInput.IsActionJustReleased( 'EnablePhotoMode' ) )
                GoBack();
        }
    }

    public function GoBack()
    {
        parent.OnDialogOptionSelected(0);
        parent.OnDialogOptionAccepted(0);
    }

    event OnLeaveState( nextStateName : name )
    {
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

function NR_IsSceneInPreviewState() : bool
{
    var hud : CR4ScriptedHud;
    var dialogModule : CR4HudModuleDialog;
	var stateName : name;
    
    hud = (CR4ScriptedHud)theGame.GetHud();
    
    if (hud)
    {
        dialogModule = hud.GetDialogModule();
        stateName = dialogModule.GetCurrentStateName();
		if ( stateName == 'NR_ScenePreviewAppearance_DialogState' || stateName == 'NR_ScenePreviewSpells_DialogState' ) {
			return true;
		}
    }
	return false;
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
