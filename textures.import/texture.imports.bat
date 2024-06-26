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

::robocopy %DIR_PROJECT_BASE%\textures.import\data\gameplay\gui_new\icons\inventory\potions\ %DIR_PROJECT_BASE%\uncooked.textures\dlc\dlcnewreplacers\data\gameplay\gui_new\icons\inventory\potions\ nr_chameleon-potion-64x64.png

:: last parameter can be set to define texturegroup if necessary, like this:
::
:: %BIN_IMPORT_TEXTURE% <srctexture.png> /data/textures/<targetname>.xbm WorldDiffuseWithAlpha
::
:: dlc/dlcnewreplacers/data/textures/fire/fire_ball6_tiled_white.xbm
:: dlc\dlcnewreplacers\data\textures\
::
::%BIN_IMPORT_TEXTURE% data/textures/projectile_fx/fire_anim_04_grey.png data/textures/projectile_fx/fire_anim_04_grey.xbm Particles

%BIN_IMPORT_TEXTURE% data/textures/fire/fire_line_01_white.png data/textures/fire/fire_line_01_white.xbm ParticlesWithoutAlpha

%BIN_IMPORT_TEXTURE% data/textures/fire/fire_tileable_2_white.png data/textures/fire/fire_tileable_2_white.xbm ParticlesWithoutAlpha

%BIN_IMPORT_TEXTURE% data/textures/fire/fire_anim_04_white.png data/textures/fire/fire_anim_04_white.xbm Particles

%BIN_IMPORT_TEXTURE% data/textures/fire/fire_mid_2k_white.png data/textures/fire/fire_mid_2k_white.xbm Particles

%BIN_IMPORT_TEXTURE% data/textures/fire/fire_tileable_white.png data/textures/fire/fire_tileable_white.xbm ParticlesWithoutAlpha

%BIN_IMPORT_TEXTURE% data/textures/fire/fire_spark_04_white.png data/textures/fire/fire_spark_04_white.xbm ParticlesWithoutAlpha

%BIN_IMPORT_TEXTURE% data/textures/fire/torch_flame_02_white.png data/textures/fire/torch_flame_02_white.xbm Particles
%BIN_IMPORT_TEXTURE% data/textures/fire/torch_flame_09_anim_white.png data/textures/fire/torch_flame_09_anim_white.xbm Particles

%BIN_IMPORT_TEXTURE% data/textures/fire/fire_ball6_tiled_white.png data/textures/fire/fire_ball6_tiled_white.xbm Particles

%BIN_IMPORT_TEXTURE% data/textures/smoke/puffy_smoke_8x8_red.png data/textures/smoke/puffy_smoke_8x8_red.xbm Particles
%BIN_IMPORT_TEXTURE% data/textures/smoke/smoke_tileable_red.png data/textures/smoke/smoke_tileable_red.xbm ParticlesWithoutAlpha

:: magic ship
%BIN_IMPORT_TEXTURE% data/textures/nilfgaardian_sail.png data/textures/nilfgaardian_sail.xbm WorldDiffuse
%BIN_IMPORT_TEXTURE% data/textures/nilfgaardian_sail_n.png data/textures/nilfgaardian_sail_n.xbm NormalmapGloss
%BIN_IMPORT_TEXTURE% data/textures/nilfgaardian_sail_sign.png data/textures/nilfgaardian_sail_sign.xbm WorldDiffuse
%BIN_IMPORT_TEXTURE% data/textures/nilfgaardian_sail_sign_n.png data/textures/nilfgaardian_sail_sign_n.xbm NormalmapGloss
%BIN_IMPORT_TEXTURE% data/textures/large_nilfgaardian_ship_sail_proxy_d.png data/textures/large_nilfgaardian_ship_sail_proxy_d.xbm DiffuseNoMips
:: Stuff
%BIN_IMPORT_TEXTURE% data/textures/spears_gold_d01.png data/textures/spears_gold_d01.xbm WorldDiffuse
:: PoP Cross
%BIN_IMPORT_TEXTURE% data/textures/signs_icons_cross.png data/textures/signs_icons_cross.xbm Particles
%BIN_IMPORT_TEXTURE% data/textures/rock_signs_cross.png data/textures/rock_signs_cross.xbm WorldDiffuseWithAlpha
%BIN_IMPORT_TEXTURE% data/textures/candle_flame_02_blue.png data/textures/candle_flame_02_blue.xbm WorldDiffuseWithAlpha
%BIN_IMPORT_TEXTURE% data/textures/torch_fire_loop_12x5_blue.png data/textures/torch_fire_loop_12x5_blue.xbm QualityColor
:: Ice Golem
%BIN_IMPORT_TEXTURE% data/textures/nr_golem_d01.tga data/textures/nr_golem_d01.xbm WorldDiffuse

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
