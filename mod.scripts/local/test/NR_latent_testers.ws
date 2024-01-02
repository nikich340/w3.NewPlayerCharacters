class INR_LatentTester extends CObject {
	public function Init() {}
	public function Stop() {
		GotoState('Inactive');
	}
}

state Inactive in INR_LatentTester {}


class NR_LatentTesterScenes extends INR_LatentTester {
	var start : int;
	var cs_only : bool;

	public function Init() {

	}

	public function Work(_start : int, _cs_only : bool) {
		start = _start;
		cs_only = _cs_only;
		GotoState('Active');
	}
}

state Active in NR_LatentTesterScenes {
	var idx : int;
	var scenePaths : array<String>;
	var hasCutscene : array<bool>;
	var inputNames : array<array<String>>;

	event OnEnterState( prevStateName : name ) {
		Run();
	}

	entry function Run() {
		var scene : CStoryScene;
		var scenePath, inputsRaw, input : String;
		var sceneInputs : array<String>;
		var hasCs : bool;
		var csv : C2dArray;
		var i, j : int;

		csv = LoadCSV("dlc/dlcnewreplacers/data/scenes/scenes_inputs_vanilla.csv");
		for (i = 0; i < csv.GetNumRows(); i += 1) {
			scenePath = csv.GetValueAt(0, i);
			sceneInputs.Clear();
			hasCs = (bool)StringToInt(csv.GetValueAt(1, i));
			if (parent.cs_only && !hasCs)
				continue;

			inputsRaw = csv.GetValueAt(2, i);
			while (StrSplitFirst(inputsRaw, "|", input, inputsRaw)) {
				sceneInputs.PushBack(input);
			}
			sceneInputs.PushBack(inputsRaw);

			scenePaths.PushBack(scenePath);
			hasCutscene.PushBack(hasCs);
			inputNames.PushBack(sceneInputs);
			NR_Debug("Loaded scene: " + scenePath + ", inputs: " + sceneInputs.Size());
		}
		NR_Notify("Loaded scenes: " + scenePaths.Size());
		Sleep(2.f);

		for (i = parent.start; i < scenePaths.Size(); i += 1) {
			for (j = 0; j < inputNames[i].Size(); j += 1) {
				scene = (CStoryScene)LoadResourceAsync(scenePaths[i], true);
				if (!scene) {
					NR_Notify("Error loading: " + scenePaths[i]);
				}
				while ( !theGame.IsActive() || theGame.IsDialogOrCutscenePlaying() 
						|| thePlayer.IsInNonGameplayCutscene() || thePlayer.IsInGameplayScene() 
        				|| theGame.IsFading() )
					Sleep(0.2f);
				
				theGame.GetStorySceneSystem().PlayScene( scene, inputNames[i][j] );
				NR_Notify("Play: [" + i + "][" + inputNames[i][j] + "] " + scenePaths[i]);
				Sleep(0.2f);
			}	
		}
	}

	event OnLeaveState( nextStateName : name ) {
		
	}
}

exec function nr_scenetest(start: int, cs_only : bool) {
	var tester : NR_LatentTesterScenes;
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	tester = new NR_LatentTesterScenes in manager;
	tester.Init();
	tester.Work(start, cs_only);
	manager.m_debugObject = tester;
}

exec function nr_scenetesterstop() {
	var tester : NR_LatentTesterScenes;
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	tester = (NR_LatentTesterScenes)manager.m_debugObject;
	if (tester)
		tester.Stop();
}
