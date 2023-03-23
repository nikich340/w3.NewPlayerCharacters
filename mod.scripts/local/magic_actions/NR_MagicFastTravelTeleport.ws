statemachine class NR_MagicFastTravelTeleport extends NR_MagicAction {
	protected var m_targetPinTag 	: name;
	protected var m_targetAreaId 	: EAreaName;
	protected var m_currentAreaId 	: EAreaName;
	protected var m_activeTime 		: float;
	protected var m_teleportPos 	: Vector;

	default actionType = ENR_FastTravelTeleport;
	default m_activeTime = 15.f;

	latent function SetTravelData(pinTag : name, areaId : EAreaName, currentAreaId : EAreaName) {
		m_targetPinTag = pinTag;
		m_targetAreaId = areaId;
		m_currentAreaId = currentAreaId;
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_fast_travel_teleport");
		pos 			= thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 0.5f + Vector(0,0,1.f);
		m_teleportPos 	= thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 5.0f + Vector(0,0,1.f);

		m_teleportPos = TraceToPoint(pos, m_teleportPos);
		m_teleportPos = SnapToGround(m_teleportPos);
		m_teleportPos.Z += 1.f;
		// can't create teleport without player teleported instantly
		if (VecDistanceSquared(pos, m_teleportPos) < 1.f) {
			NRD("NR_MagicFastTravelTeleport: Can't create teleport without player teleported instantly");
			return OnPrepared(false);
		}

		dummyEntity = theGame.CreateEntity(entityTemplate, m_teleportPos, thePlayer.GetWorldRotation());
		if (!dummyEntity) {
			NRE("NR_MagicFastTravelTeleport: teleport = " + dummyEntity + ", template = " + entityTemplate);
		}
		m_fxNameMain = TeleportFxName();

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		GotoState('Active');
		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (!isPrepared || isPerformed) {
			return;
		}
		super.BreakAction();
		GotoState('Inactive');
	}

	latent function TeleportFxName() : name {
		var color 	: ENR_MagicColor = NR_GetActionColor();
		return 'teleport';
		// TODO!!
	}
}

state Active in NR_MagicFastTravelTeleport {
	protected var startTime : float;

	event OnEnterState( prevStateName : name )
	{
		NRD("NR_MagicFastTravelTeleport: Active: OnEnterState");
		parent.inPostState = true;
		parent.dummyEntity.PlayEffect( parent.m_fxNameMain );
		MainLoop();
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_MagicFastTravelTeleport: Active: OnLeaveState");
		parent.inPostState = false;
		parent.dummyEntity.StopEffect( parent.m_fxNameMain );
		parent.dummyEntity.DestroyAfter(5.f);
	}

	function GetLocalTime() : float {
		return EngineTimeToFloat(theGame.GetEngineTime()) - startTime;
	}

	entry function MainLoop() {
		var dist : float;

		startTime = EngineTimeToFloat(theGame.GetEngineTime());
		while (parent.m_activeTime > GetLocalTime()) {
			dist = VecDistanceSquared(parent.m_teleportPos, thePlayer.GetWorldPosition() + Vector(0,0,1.f));
			// 0.8^2
			if (dist < 0.64) {
				PerformFastTravel();
				break;
			}
			Sleep(0.1f);
		}
		parent.GotoState('Inactive');
	}

	latent function PerformFastTravel() {
		var manager	: CCommonMapManager = theGame.GetCommonMapManager();

		NR_Notify("PerformFastTravel: pinTag = " + parent.m_targetPinTag + ", area = " + parent.m_targetAreaId);
		if ( !manager )
		{
			return;
		}
		manager.UseMapPin( parent.m_targetPinTag, true );
		// hack to make smooth fadeOut and avoid persistent blackscreen
		theGame.FadeOut(1.f);
		theGame.FadeInAsync(0.5f);
		if ( parent.m_currentAreaId == parent.m_targetAreaId )
		{
			manager.PerformLocalFastTravelTeleport( parent.m_targetPinTag );
		} else {
			manager.PerformGlobalFastTravelTeleport( parent.m_targetAreaId, parent.m_targetPinTag );
		}
	}
}

state Inactive in NR_MagicFastTravelTeleport {
	event OnEnterState( prevStateName : name )
	{
		NRD("NR_MagicFastTravelTeleport: Inactive: OnEnterState");
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_MagicFastTravelTeleport: Inactive: OnLeaveState");
	}
}
