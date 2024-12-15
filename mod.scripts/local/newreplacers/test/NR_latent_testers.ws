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
			// NR_Debug("Loaded scene: " + scenePath + ", inputs: " + sceneInputs.Size());
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

class NR_LatentTesterLines extends INR_LatentTester {
	var lineIds : array<int>;

	public function Init() {
		lineIds.PushBack(1163321); // vanilla Geralt
		lineIds.PushBack(2100000055); // vanilla
		lineIds.PushBack(2115940060); // CPC
		lineIds.PushBack(2115940731); // CPC - battlecries
		lineIds.PushBack(2100020349); // Boat Races
		lineIds.PushBack(2100020002); // Ciri Sole Memento
		lineIds.PushBack(2100020372); // Expansion Zero
		lineIds.PushBack(2100020018); // Little Sisters
		lineIds.PushBack(2100020089); // ANTR
		lineIds.PushBack(2100020124); // hubtest
		lineIds.PushBack(2100020129); // Small Tribute to Essi
		lineIds.PushBack(2100020231); // Strange Things
	}

	public function Work() {
		GotoState('Active');
	}
}

state Active in NR_LatentTesterLines {
	event OnEnterState( prevStateName : name ) {
		Run();
	}

	entry function Run() {
		var i : int;

		for (i = 0; i < parent.lineIds.Size(); i += 1) {
			NR_Notify("Play line [" + (i + 1) + "/" + parent.lineIds.Size() + "] " + parent.lineIds[i]);
			thePlayer.PlayLine(parent.lineIds[i], true);
			thePlayer.WaitForEndOfSpeach();
		}
	}
}

// nrscene(quests/part_1/quest_files/q103_daughter/scenes/q103_11b_baron_about_botch.w2scene, won)
exec function nr_linetest() {
	var tester : NR_LatentTesterLines;
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	tester = new NR_LatentTesterLines in manager;
	tester.Init();
	tester.Work();
	manager.m_debugObject = tester;
}
