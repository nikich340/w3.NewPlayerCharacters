statemachine class NR_AdvancedNPC extends CNewNPC {
	protected var commentScene : CStoryScene;
	protected var commentTimeIntervalMin : float;
	protected var commentTimeIntervalMax : float;
	protected var commentCombatStartChance : int;
	protected var commentCombatEndChance : int;
	protected var commentInputNames : array<String>;
	protected var commentCombatStartInputNames : array<String>;
	protected var commentCombatEndInputNames : array<String>;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		NR_Debug("NR_AdvancedNPC.OnSpawned");
		AddTimer('PlayVoicesetTimer', NR_GetRandomGenerator().nextRangeF(commentTimeIntervalMin, commentTimeIntervalMax), false);
	}

	timer function PlayVoicesetTimer( time : float , id : int)
	{
		AddTimer('PlayVoicesetTimer', NR_GetRandomGenerator().nextRangeF(commentTimeIntervalMin, commentTimeIntervalMax), false);
		NR_Debug("NR_AdvancedNPC.PlayVoicesetTimer");
		if ( !IsInCombat() && commentInputNames.Size() > 0 )
		{
			NR_Debug("NR_AdvancedNPC.PlayVoicesetTimer: Play");
			PlayComment( commentInputNames[NR_GetRandomGenerator().next(commentInputNames.Size())] );
		}
	}
	
	protected function OnCombatModeSet( toggle : bool )
	{
		var chance : int;

		super.OnCombatModeSet( toggle );
		NR_Debug("NR_AdvancedNPC.OnCombatModeSet");
		if (toggle && commentCombatStartInputNames.Size() > 0 && commentCombatStartChance >= NR_GetRandomGenerator().nextRange(1, 100)) {
			PlayComment( commentCombatStartInputNames[NR_GetRandomGenerator().next(commentCombatStartInputNames.Size())] );
		} else if (!toggle && commentCombatEndInputNames.Size() > 0 && commentCombatEndChance >= NR_GetRandomGenerator().nextRange(1, 100)) {
			PlayComment( commentCombatEndInputNames[NR_GetRandomGenerator().next(commentCombatEndInputNames.Size())] );
		}
		NR_Debug("(" + this + ") OnCombatModeSet = " + toggle);
	}

	protected function PlayComment(inputName : String) {
		theGame.GetStorySceneSystem().PlayScene( commentScene, inputName );
	}
}
