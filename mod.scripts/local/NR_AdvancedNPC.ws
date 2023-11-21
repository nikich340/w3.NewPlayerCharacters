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
		NRD("NR_AdvancedNPC.OnSpawned");
		AddTimer('PlayVoicesetTimer', RandRangeF(commentTimeIntervalMax, commentTimeIntervalMin), false);
	}

	timer function PlayVoicesetTimer( time : float , id : int)
	{
		AddTimer('PlayVoicesetTimer', RandRangeF(commentTimeIntervalMax, commentTimeIntervalMin), false);
		NRD("NR_AdvancedNPC.PlayVoicesetTimer");
		if( !IsInCombat() && commentInputNames.Size() > 0 )
		{
			NRD("NR_AdvancedNPC.PlayVoicesetTimer: Play");
			PlayComment( commentInputNames[RandRange(commentInputNames.Size())] );
		}
	}
	
	protected function OnCombatModeSet( toggle : bool )
	{
		var chance : int;

		super.OnCombatModeSet( toggle );
		NRD("NR_AdvancedNPC.OnCombatModeSet");
		if (toggle && commentCombatStartInputNames.Size() > 0 && commentCombatStartChance >= NR_GetRandomGenerator().nextRange(1, 100)) {
			PlayComment( commentCombatStartInputNames[RandRange(commentCombatStartInputNames.Size())] );
		} else if (!toggle && commentCombatEndInputNames.Size() > 0 && commentCombatEndChance >= NR_GetRandomGenerator().nextRange(1, 100)) {
			PlayComment( commentCombatEndInputNames[RandRange(commentCombatEndInputNames.Size())] );
		}
		NRD("(" + this + ") OnCombatModeSet = " + toggle);
	}

	protected function PlayComment(inputName : String) {
		theGame.GetStorySceneSystem().PlayScene( commentScene, inputName );
	}
}
