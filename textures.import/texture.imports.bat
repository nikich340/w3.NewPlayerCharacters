::
:: will be called at texture import step
::
@echo off
:: ---------------------------------------------------
:: --- check for settings
:: ---------------------------------------------------
IF %SETTINGS_LOADED% EQU 1 goto :SettingsLoaded

echo ERROR! Settings not loaded! - do not start this file directly!
EXIT /B 1

:SettingsLoaded

:: ---------------------------------------------------
:: add one line for every texture to import
::
:: %BIN_IMPORT_TEXTURE% <srcimage> <targetpath>.xbm <optional texturegroup>
::
:: e.g.:
::  %BIN_IMPORT_TEXTURE% data/entities/meshes/ciri_hw_clumping.png data/entities/meshes/ciri_hw_clumping.xbm



:: last parameter can be set to define texturegroup if necessary, like this:
::
:: %BIN_IMPORT_TEXTURE% <srctexture.png> /data/textures/<targetname>.xbm WorldDiffuseWithAlpha
:: dlc/dlcnewreplacers/data/particles
%BIN_IMPORT_TEXTURE% data/particles/smoke_tileable_red.png data/particles/smoke_tileable_red.xbm ParticlesWithoutAlpha
%BIN_IMPORT_TEXTURE% data/particles/puffy_smoke_8x8_red.png data/particles/puffy_smoke_8x8_red.xbm Particles

::
:: default texturegroup is: WorldDiffuse
:: Supported texture group names:
::       BillboardAtlas
::       CharacterDiffuse
::       CharacterDiffuseWithAlpha
::       CharacterEmissive
::       CharacterNormal
::       CharacterNormalHQ
::       CharacterNormalmapGloss
::       Default
::       DetailNormalMap
::       DiffuseNoMips
::       Flares
::       FoliageDiffuse
::       Font
::       GUIWithAlpha
::       GUIWithoutAlpha
::       HeadDiffuse
::       HeadDiffuseWithAlpha
::       HeadEmissive
::       HeadNormal
::       HeadNormalHQ
::       MimicDecalsNormal
::       NormalmapGloss
::       NormalsNoMips
::       Particles
::       ParticlesWithoutAlpha
::       PostFxMap
::       QualityColor
::       QualityOneChannel
::       QualityTwoChannels
::       SpecialQuestDiffuse
::       SpecialQuestNormal
::       SystemNoMips
::       TerrainDiffuse
::       TerrainNormal
::       WorldDiffuse
::       WorldDiffuseWithAlpha
::       WorldEmissive
::       WorldNormal
::       WorldNormalHQ
::       WorldSpecular
