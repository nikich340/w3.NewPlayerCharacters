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
	FactsAdd("nr_magic_skill_ENR_SpecialWeatherChange", 1);
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

exec function testlipv() {
	thePlayer.PlayLine(182702, true);
}

exec function testlip() {
	thePlayer.PlayLine(2100012687, true);
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
	FactsAdd("nr_magic_skill_ENR_SpecialWeatherChange", 1);
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
	
	thePlayer.PlayLine(2100003561, true);
}
