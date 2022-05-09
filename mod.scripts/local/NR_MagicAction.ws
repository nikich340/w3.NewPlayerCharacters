abstract statemachine class NR_MagicAction {
	latent function MakeAeltothHappy (howHappy : EHappiness) {
		var entityTemplate 			: CEntityTemplate;

		if (howHappy == EH_MakeHisDay)	
		{
			while ( WeNeedNiceRest() ) {
				SleepOneFrame();
			}
			entityTemplate = (CEntityTemplate)LoadResourceAsync('i_couldnt_trouble');
		}
	}
}