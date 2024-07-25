statemachine class NR_MagicSpecialWeatherChange extends NR_MagicSpecialAction {
	var weathers : array<name>;
	var weatherIndex : int;
	default actionType = ENR_SpecialWeatherChange;
	default actionSubtype = ENR_SpecialAbstract;
	default maxLevelup 		  = 1; // action-specific

	latent function OnInit() : bool {
		sceneInputs.PushBack(18);
		sceneInputs.PushBack(19);
		sceneInputs.PushBack(20);
		sceneInputs.PushBack(21);
		super.OnInit();

		return true;
	}

	latent function OnPrepare() : bool {
		var currentWeather : name;

		super.OnPrepare();

		// fix - no actions on cursing
		s_curseChance = 0;
		theSound.SoundLoadBank("fx_other.bnk", true);
		weathers.PushBack('WT_Clear');
		weathers.PushBack('WT_Light_Clouds');
		weathers.PushBack('WT_Mid_Clouds');
		weathers.PushBack('WT_Heavy_Clouds');
		weathers.PushBack('WT_Light_Rain');
		weathers.PushBack('WT_Rain_Storm');

		currentWeather = GetWeatherConditionName();
		if ( !weathers.Contains(currentWeather) ) {
			weathers.PushBack(currentWeather);
			weatherIndex = -1;
		} else {
			weatherIndex = weathers.FindFirst(currentWeather);
		}

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var super_ret, success : bool;

		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		while (!success) {
			weatherIndex += 1;
			if (weatherIndex >= weathers.Size())
				weatherIndex = 0;
			success = RequestWeatherChangeTo(weathers[weatherIndex], 2.f, false);
		}
		thePlayer.SoundEvent("fx_rune_activate_yrden");

		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;
			
		super.BreakAction();
	}
}
