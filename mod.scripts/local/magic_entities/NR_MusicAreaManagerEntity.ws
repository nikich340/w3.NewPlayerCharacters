statemachine class NR_MusicAreaManagerEntity extends CGameplayEntity {
	editable var m_bankName 	: String;
	editable var m_inAreaFact 	: String;
	editable var m_playEvent 	: String;
	editable var m_stopEvent 	: String;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		NR_Debug("NR_MusicAreaManagerEntity: OnSpawned = " + this);
		super.OnSpawned(spawnData);
		GotoState('Active');
	}
}

state Active in NR_MusicAreaManagerEntity {
	var l_isInArea 		: bool;

	event OnEnterState( prevStateName : name )
	{
		Main();
	}

	entry function Main() {
		var isInArea 	: bool;

		theSound.SoundLoadBank( parent.m_bankName, /*async*/ true );
		while ( !theSound.SoundIsBankLoaded( parent.m_bankName ) ) {
			Sleep(0.2f);
		}

		while (true) {
			Sleep(0.5f);

			isInArea = FactsQuerySum( parent.m_inAreaFact ) > 0;
			if (isInArea) {
				if (!l_isInArea) {
					// enter area
					theSound.SoundEvent( "stop_music" );
					theSound.SoundEvent( parent.m_playEvent );
				}
			} else {
				if (l_isInArea) {
					// exit area
					theSound.SoundEvent( parent.m_stopEvent );
					theSound.InitializeAreaMusic( theGame.GetCommonMapManager().GetCurrentArea() );
				}
			}
			l_isInArea = isInArea;
		}
	}

	event OnLeaveState( nextStateName : name )
	{
		if (l_isInArea) {
			// exit area
			theSound.SoundEvent( parent.m_stopEvent );
			theSound.InitializeAreaMusic( theGame.GetCommonMapManager().GetCurrentArea() );
		}
	}
}
