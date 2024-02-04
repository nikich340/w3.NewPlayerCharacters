exec function nrcheat() {
	FactsAdd("nr_magic_skill_ENR_HandFx", 1);
	FactsAdd("nr_magic_skill_ENR_Teleport", 1);
	FactsAdd("nr_magic_skill_ENR_CounterPush", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialLumos", 1);
	FactsAdd("nr_magic_skill_ENR_LightAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_Slash", 1);
	FactsAdd("nr_magic_skill_ENR_ThrowAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_Lightning", 1);
	FactsAdd("nr_magic_skill_ENR_ProjectileWithPrepare", 1);
	
	FactsAdd("nr_magic_skill_ENR_BombExplosion", 1);
	FactsAdd("nr_magic_skill_ENR_Rock", 1);
	FactsAdd("nr_magic_skill_ENR_RipApart", 1);
	FactsAdd("nr_magic_skill_ENR_HeavyAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_FastTravelTeleport", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialShield", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialTornado", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialControl", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialMeteor", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialServant", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialLightningFall", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialField", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialMeteorFall", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialPolymorphism", 1);
	FactsAdd("nr_magic_skill_ENR_WaterTrap", 1);
	
	thePlayer.PlayLine(2100018599, true);
}

exec function nrcheatfull() {
	FactsAdd("nr_magic_skill_ENR_HandFx", 1);
	FactsAdd("nr_magic_skill_ENR_Teleport", 1);
	FactsAdd("nr_magic_skill_ENR_CounterPush", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialLumos", 1);
	FactsAdd("nr_magic_skill_ENR_LightAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_Slash", 1);
	FactsAdd("nr_magic_skill_ENR_ThrowAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_Lightning", 1);
	FactsAdd("nr_magic_skill_ENR_ProjectileWithPrepare", 1);
	
	FactsAdd("nr_magic_skill_ENR_BombExplosion", 1);
	FactsAdd("nr_magic_skill_ENR_Rock", 1);
	FactsAdd("nr_magic_skill_ENR_RipApart", 1);
	FactsAdd("nr_magic_skill_ENR_HeavyAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_FastTravelTeleport", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialShield", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialTornado", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialControl", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialMeteor", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialServant", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialLightningFall", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialField", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialMeteorFall", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialPolymorphism", 1);
	FactsAdd("nr_magic_skill_ENR_WaterTrap", 1);

	// set max level
	NR_GetMagicManager().SetActionSkillLevel(ENR_HandFx, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Teleport, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_CounterPush, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialLumos, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_LightAbstract, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Slash, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_ThrowAbstract, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Lightning, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_ProjectileWithPrepare, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_BombExplosion, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Rock, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_RipApart, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_HeavyAbstract, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_FastTravelTeleport, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialShield, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialTornado, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialControl, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialMeteor, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialServant, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialLightningFall, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialField, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialMeteorFall, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialPolymorphism, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_WaterTrap, 10);

	// ENR_BombExplosion
	NR_GetMagicManager().ActionAbilityUnlock(ENR_BombExplosion, "Pursuit");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_BombExplosion, "DamageControl");
	
	// ENR_CounterPush
	NR_GetMagicManager().ActionAbilityUnlock(ENR_CounterPush, "FullBlast");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_CounterPush, "Freezing");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_CounterPush, "Burning");
	
	// ENR_FastTravelTeleport
	
	// ENR_Lightning
	NR_GetMagicManager().ActionAbilityUnlock(ENR_Lightning, "Rebound");
	
	// ENR_ProjectileWithPrepare
	NR_GetMagicManager().ActionAbilityUnlock(ENR_ProjectileWithPrepare, "AutoAim");
	
	// ENR_RipApart
	
	// ENR_Rock
	NR_GetMagicManager().ActionAbilityUnlock(ENR_Rock, "AutoAim");
	
	// ENR_Slash
	NR_GetMagicManager().ActionAbilityUnlock(ENR_Slash, "DoubleSlash");
	
	// ENR_Slash
	NR_GetMagicManager().ActionAbilityUnlock(ENR_Slash, "DoubleSlash");
	
	// ENR_SpecialControl
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialControl, "Upscaling");
	
	// ENR_SpecialField
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialField, "Pursuit");
	
	// ENR_SpecialLightningFall
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialLightningFall, "AutoShield");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialLightningFall, "DamageControl");
	
	// ENR_SpecialLumos
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialLumos, "DamageControl");
	
	// ENR_SpecialMeteor
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialMeteor, "DamageControl");
	
	// ENR_SpecialMeteorFall
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialMeteorFall, "AutoShield");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialMeteorFall, "DamageControl");
	
	// ENR_SpecialPolymorphism
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialPolymorphism, "DamageControl");
	
	// ENR_SpecialServant
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "barghest");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "endriaga");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "arachnomorph");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Followers");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "arachas");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "TwoServants");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "gargoyle");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "earth_elemental");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "ice_elemental");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "fire_elemental");
	
	// ENR_SpecialShield
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialShield, "AutoLightning");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialShield, "AutoCombatApply");
	
	// ENR_SpecialTornado
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialTornado, "Pursuit");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialTornado, "Suck");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialTornado, "DamageControl");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialTornado, "Freezing");

	// ENR_SpecialServant
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "TwoServants");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Barghest");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Endriaga");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Arachnomorph");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Arachas");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Followers");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Gargoyle");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "EarthElemental");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "IceElemental");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "FireElemental");
	
	thePlayer.PlayLine(2100003561, true);
}
