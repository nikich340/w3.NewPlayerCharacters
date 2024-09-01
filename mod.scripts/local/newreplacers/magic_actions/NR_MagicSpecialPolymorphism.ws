statemachine class NR_MagicSpecialPolymorphism extends NR_MagicSpecialAction {
	var transformNPC 	: CActor;
	var animalType 		: name;
	var idleActionId 	: int;
	var appearanceName 	: name;
	var forceStopRequired : bool;
	var restoredFromSave : bool;
	
	default isDamaging 	= false;
	default performsToLevelup = 10; // action-specific
	default actionType = ENR_SpecialPolymorphism;
	default actionSubtype = ENR_SpecialAbstractAlt;
	
	public function RestoreFromSave() {
		restoredFromSave = true;
		animalType = map[ST_Universal].getN("nr_polymorphysm_type", 'cat');
		appearanceName = map[ST_Universal].getN("nr_polymorphysm_appearance", 'cat_vanilla_04');
	}

	latent function OnInit() : bool {
		sceneInputs.PushBack(11);
		sceneInputs.PushBack(12);
		sceneInputs.PushBack(13);
		super.OnInit();

		return true;
	}

	latent function OnPrepare() : bool {
		var appNames 	: array<name>;
		super.OnPrepare();

		m_fxNameMain = TransformFxName();

		if (!restoredFromSave)
			animalType = map[sign].getN("style_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat');

		if (animalType == 'cat') {
			resourceName = "nr_transform_cat";

			if (!restoredFromSave) {
				if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') )
					appearanceName = map[sign].getN("cat_app_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat_20');
				else
					appearanceName = map[sign].getN("cat_app_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat_vanilla_04');

				if ( appearanceName == 'random' ) {
					if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') ) {
						GetAppearanceNames( entityTemplate, appNames );
						appNames.Remove('cat_vanilla_01');
						appNames.Remove('cat_vanilla_02');
						appNames.Remove('cat_vanilla_03');
						appNames.Remove('cat_vanilla_04');
					} else {
						appNames.PushBack('cat_vanilla_01');
						appNames.PushBack('cat_vanilla_02');
						appNames.PushBack('cat_vanilla_03');
						appNames.PushBack('cat_vanilla_04');
						appNames.PushBack('fox_red');
						appNames.PushBack('fox_silverish');
						appNames.PushBack('fox_black');
					}
					appearanceName = appNames[ NR_GetRandomGenerator().next(appNames.Size()) ];
				}
			}
		} else if (animalType == 'crow') {
			resourceName = "nr_transform_crow";

			if (!restoredFromSave)
				appearanceName = 'crow_01';
		} else if (animalType == 'owl') {
			resourceName = "nr_transform_owl";

			if (!restoredFromSave)
				appearanceName = 'owl_01';
		} else {
			NR_Error("NR_MagicSpecialPolymorphism: Unknown animalType = " + animalType);
			return OnPrepared(false);
		}
		NR_Info("NR_MagicSpecialPolymorphism: animalType = " + animalType + ", appearanceName = " + appearanceName);
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		
		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var aiTree 		: CAIIdleTree;
		var super_ret 	: bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		thePlayer.PlayEffect(m_fxNameMain);
		if (!restoredFromSave)
			Sleep(0.3f);

		pos = thePlayer.GetWorldPosition();
		if (animalType == 'crow' || animalType == 'owl') {
			pos.Z += 2.f;
		}
		rot = thePlayer.GetWorldRotation();
		transformNPC = (CActor)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!transformNPC) {
			NR_Error("transformNPC is invalid.");
			return OnPerformed(false);
		}
		transformNPC.PlayEffect('appear');
		transformNPC.ApplyAppearance( appearanceName );
		transformNPC.AddTag('NR_TRANSFORM_NPC');
		transformNPC.SetAttitude( thePlayer, AIA_Friendly );

		if (IsInSetupScene()) {
			// fast transform without changing thePlayer state
			if (animalType == 'cat') {
				pos.Z += 1.f;
			}
			transformNPC.EnablePhysicalMovement(true);
			((CMovingPhysicalAgentComponent)transformNPC.GetMovingAgentComponent()).SetAnimatedMovement(true);
			((CMovingPhysicalAgentComponent)transformNPC.GetMovingAgentComponent()).SetGravity(false);
			transformNPC.Teleport(pos);

			NR_GetMagicManager().HandFX(false);
			thePlayer.SetVisibility(false);
			Sleep(2.5f);
			transformNPC.PlayEffect('disappear');
			thePlayer.PlayEffect(m_fxNameMain);
			thePlayer.SetVisibility(true);
			NR_GetMagicManager().HandFX(true, false);

			transformNPC.DestroyAfter(2.f);
			return OnPerformed(true);
		}

		/*
		su_oneliner = SU_onelinerEntity(
			"",
			transformNPC
		);
		su_oneliner.setOffset( Vector(0, 0, 0.5f) );
		su_oneliner.setRenderDistance( 100 );
		su_oneliner.visible = false;
		*/

		thePlayer.CreateAttachment(transformNPC);
		NR_Info("NR_SpecialPolymorphism: goto transformed state, animalType = " + animalType);
		NR_GetMagicManager().SetPolymorphismAnimalType(animalType);
		if (animalType == 'cat') {
			thePlayer.GotoState('NR_TransformedCat', false);
		} else if (animalType == 'crow' || animalType == 'owl') {
			thePlayer.GotoState('NR_TransformedCrow', false);
		}
		map[ST_Universal].setI("nr_polymorphysm_active", 1);
		map[ST_Universal].setN("nr_polymorphysm_type", animalType);
		map[ST_Universal].setN("nr_polymorphysm_appearance", appearanceName);

		this.GotoState('Active');
		return OnPerformed(true);
	}
	
	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		GotoState('Stop');
	}

	// synced force stop
	public function ForceStop() {
		forceStopRequired = true;
		GotoState('Stop');
	}

	latent function TransformFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'teleport_appear_yellow';
			case ENR_ColorOrange:
				return 'teleport_appear_orange';
			case ENR_ColorRed:
				return 'teleport_appear_red';
			case ENR_ColorPink:
				return 'teleport_appear_pink';
			case ENR_ColorBlue:
				return 'teleport_appear_blue';
			case ENR_ColorSeagreen:
				return 'teleport_appear_seagreen';
			case ENR_ColorGreen:
				return 'teleport_appear_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
				return 'teleport_appear_white';
			case ENR_ColorViolet:
			default:
				return 'teleport_appear_violet';
		}
	}
}

state Active in NR_MagicSpecialPolymorphism {
	var sorceress : NR_ReplacerSorceress;

	entry function ActiveLoop() {
		sorceress = NR_GetReplacerSorceress();

		if (!parent.restoredFromSave)
			Sleep(0.5f);

		// show base tutorial
		if (FactsQuerySum("nr_quest_track_PolymorphismWarning") < 1) {
			NR_ShowTutorial("PolymorphismWarning", true);
		}

		while (true) {
			SleepOneFrame();
			if ( theInput.GetActionValue( 'CastSignHold' ) > 0.f ) {
				break;
			}
		}

		// NR_Debug("StopAction: " + this);
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
}

state Stop in NR_MagicSpecialPolymorphism {
	entry function StopLoop() {
		if ( !parent.forceStopRequired ) {
			parent.transformNPC.PlayEffect('disappear');
			Sleep(0.5f);
		}
		
		parent.map[parent.ST_Universal].removeKey("nr_polymorphysm_active");
		parent.transformNPC.SetVisibility(false);
		thePlayer.BreakAttachment();

		thePlayer.PlayEffect(parent.m_fxNameMain);
		
		parent.transformNPC.StopAllEffects();
		parent.transformNPC.DestroyAfter(1.f);
		if ( !parent.forceStopRequired )
			thePlayer.GotoState('Exploration', false);
		parent.inPostState = false;
	}
}

state Cursed in NR_MagicSpecialPolymorphism {
	entry function CursedLoop() {
		// do nothing
		parent.StopAction();
	}
}
