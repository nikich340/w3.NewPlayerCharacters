statemachine class NR_FastTravelTeleport extends CGameplayEntity
{
	public var m_targetPinTag	: name;
	public var m_targetAreaId	: EAreaName;
	public var m_currentAreaId	: EAreaName;
	public var m_fxName 		: name;
	public var m_activeTime		: float;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}

	public function Activate() {
		GotoState('Active');
	}

	public function Deactivate() {
		GotoState('Inactive');
	}
}

state Active in NR_FastTravelTeleport {
	protected var startTime 		: float;

	event OnEnterState( prevStateName : name )
	{
		NRD("NR_FastTravelTeleport: Active: OnEnterState");
		parent.PlayEffect( parent.m_fxName );
		MainLoop();
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_FastTravelTeleport: Active: OnLeaveState");
		parent.StopEffect( parent.m_fxName );
	}

	function GetLocalTime() : float {
		return EngineTimeToFloat(theGame.GetEngineTime()) - startTime;
	}

	entry function MainLoop() {
		var dist : float;

		startTime = EngineTimeToFloat(theGame.GetEngineTime());
		while (parent.m_activeTime > GetLocalTime()) {
			dist = VecDistanceSquared(parent.GetWorldPosition(), thePlayer.GetWorldPosition());
			// 0.7^2
			if (dist < 0.49) {
				PerformFastTravel();
				break;
			}
			Sleep(0.2f);
		}
		parent.Deactivate();
	}

	latent function PerformFastTravel() {
		var manager	: CCommonMapManager = theGame.GetCommonMapManager();

		NR_Notify("PerformFastTravel: pinTag = " + parent.m_targetPinTag + ", area = " + parent.m_targetAreaId);
		if ( !manager )
		{
			return;
		}
		manager.UseMapPin( parent.m_targetPinTag, true );
		if ( parent.m_currentAreaId == parent.m_targetAreaId )
		{
			manager.PerformLocalFastTravelTeleport( parent.m_targetPinTag );
		} else {
			manager.PerformGlobalFastTravelTeleport( parent.m_targetAreaId, parent.m_targetPinTag );
		}
	}
}

state Inactive in NR_FastTravelTeleport {
	event OnEnterState( prevStateName : name )
	{
		NRD("NR_FastTravelTeleport: Stop: OnEnterState");
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_FastTravelTeleport: Stop: OnLeaveState");
	}
}
