class NR_AdvancedGameplayEntity extends CGameplayEntity
{
    var preloadEffectsOnStartup : array<name>;

    event OnSpawned( spawnData : SEntitySpawnData )
    {
        var i : int;

        for (i = 0; i < preloadEffectsOnStartup.Size(); i += 1) {
            PreloadEffect(preloadEffectsOnStartup[i]);
        }
        super.OnSpawned( spawnData );
    }
}
