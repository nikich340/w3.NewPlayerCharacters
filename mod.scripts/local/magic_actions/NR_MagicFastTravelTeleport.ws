statemachine class NR_MagicFastTravelTeleport extends NR_MagicAction {
	protected var m_targetPinTag 	: name;
	protected var m_targetAreaId 	: EAreaName;
	protected var m_currentAreaId 	: EAreaName;
	protected var m_activeTime 		: float;
	protected var m_teleportZ 		: float;
	protected var m_teleportPos 	: Vector;
	protected var m_doStaticTrace 	: bool;

	default actionType = ENR_FastTravelTeleport;
	default m_teleportZ = 1.f;
	default m_activeTime = 15.f;
	default m_doStaticTrace = true;
	default performsToLevelup = 10;

	latent function SetTravelData(pinTag : name, areaId : EAreaName, currentAreaId : EAreaName) {
		m_targetPinTag = pinTag;
		m_targetAreaId = areaId;
		m_currentAreaId = currentAreaId;
	}

	latent function SetActiveTime(activeTime : float) {
		m_activeTime = activeTime;
	}

	latent function SetDoStaticTrace(doStaticTrace : bool) {
		m_doStaticTrace = doStaticTrace;
	}

	latent function OnPrepare() : bool {
		var templateName : String;
		var safePosFound : bool;
		super.OnPrepare();

		templateName = TeleportEntityName();
		entityTemplate = (CEntityTemplate)LoadResourceAsync(templateName, true);
		pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 0.5f + Vector(0,0,1.f);
		rot = thePlayer.GetWorldRotation();

		if (IsInSetupScene()) {
			m_teleportPos = MidPosInScene(/*far*/ true);
			rot.Yaw += 90.f;
		} else {
			m_teleportPos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 5.0f;
		}

		if (m_doStaticTrace) {
			m_teleportPos.Z += 1.f;
			m_teleportPos = TraceToPoint(pos, m_teleportPos);
			m_teleportPos.Z -= 1.f;
		}

		if (IsInSetupScene()) {
			safePosFound = true;
		} else {
			safePosFound = NR_GetSafeTeleportPoint( m_teleportPos );
		}
		m_teleportZ = TeleportZ();
		m_teleportPos.Z += m_teleportZ;

		// can't create teleport without player teleported instantly
		if ( !safePosFound ) {
			NRD("NR_MagicFastTravelTeleport: Can't find safe pos");
			thePlayer.DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_here" ));
			return OnPrepared(false);
		}
		if ( VecDistanceSquared(pos, m_teleportPos) < 1.5f ) {
			NRD("NR_MagicFastTravelTeleport: Teleport pos is too close");
			thePlayer.DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_here" ));
			return OnPrepared(false);
		}

		dummyEntity = theGame.CreateEntity(entityTemplate, m_teleportPos, rot);
		NRD("NR_MagicFastTravelTeleport: teleport = " + dummyEntity + ", template = " + entityTemplate);
		if (!dummyEntity) {
			NRD("NR_MagicFastTravelTeleport: teleport = " + dummyEntity + ", template = " + entityTemplate);
		}
		m_fxNameMain = 'teleport_fx';
		m_fxNameExtra = HandFxName();

		if (!thePlayer.IsInNonGameplayCutscene())
			thePlayer.PlayEffect(m_fxNameExtra);

		if (IsInSetupScene()) {
			m_activeTime = 3.f;
		}

		return OnPrepared(true);
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false, scriptedPerform);
		}

		GotoState('Active');
		if (!thePlayer.IsInNonGameplayCutscene())
			thePlayer.StopEffect(m_fxNameExtra);
		return OnPerformed(true, scriptedPerform);
	}

	latent function BreakAction() {
		if (!isPrepared || isPerformed) {
			return;
		}
		super.BreakAction();
		thePlayer.StopEffect(m_fxNameExtra);
		GotoState('Inactive');
	}

	latent function TeleportEntityName() : String {
		var typeName 	: name = map[sign].getN("style_" + ENR_MAToName(actionType));
		var color 		: ENR_MagicColor = NR_GetActionColor();
		var result 		: String;

		result = "dlc/dlcnewreplacers/data/entities/magic/ft_teleport/";
		switch (typeName) {
			case 'wild_hunt':
				result += "nr_sq210_portal_big";
				break;
			case 'keira':
				result += "nr_q109_keira_teleport";
				break;
			case 'default':
			default:
				result += "nr_teleport_01";
				break;
		}
		result += "_" + ENR_MCToStringShort(color) + ".w2ent";
		NRD("TeleportEntityName = " + result);
		return result;
	}

	latent function TeleportZ() : float {
		var typeName : name = map[sign].getN("style_" + ENR_MAToName(actionType));
		switch (typeName) {
			case 'wild_hunt':
				return 0.f;
			case 'keira':
				return 0.f;
			case 'triss':
			default:
				return 1.2f;
		}
	}

	latent function HandFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'q210_portal_spell_yellow';
			case ENR_ColorOrange:
				return 'q210_portal_spell_orange';
			case ENR_ColorRed:
				return 'q210_portal_spell_red';
			case ENR_ColorPink:
				return 'q210_portal_spell_pink';
			case ENR_ColorViolet:
				return 'q210_portal_spell_violet';
			case ENR_ColorBlue:
				return 'q210_portal_spell_blue';
			case ENR_ColorSeagreen:
				return 'q210_portal_spell_seagreen';
			case ENR_ColorGreen:
				return 'q210_portal_spell_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
			default:
				return 'q210_portal_spell_white';
		}
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
			dist = VecDistanceSquared(parent.m_teleportPos, thePlayer.GetWorldPosition() + Vector(0,0,parent.m_teleportZ));
			// 1.0^2
			if (dist < 1.f) {
				PerformFastTravel();
				break;
			}
			Sleep(0.1f);
		}
		parent.GotoState('Inactive');
	}

	latent function PerformFastTravel() {
		var manager	: CCommonMapManager = theGame.GetCommonMapManager();

		NRD("PerformFastTravel: pinTag = " + parent.m_targetPinTag + ", area = " + parent.m_targetAreaId);
		if ( !manager )
		{
			return;
		}
		manager.UseMapPin( parent.m_targetPinTag, true );
		// hack to make smooth fadeOut and avoid persistent blackscreen
		theGame.FadeOut(0.5f);
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
