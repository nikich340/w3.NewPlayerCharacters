@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

rem ---------------------------------------------------

:: e.g. SET TEXTUREFILE=data/entities/meshes/clumping.png
SET TEXTUREFILE=

SET INTERACTIVE_BUILD=0

SET PATCH_MODE=1

SET WCC_IMPORT_TEXTURES=1

SET START_GAME=1

call "%DIR_PROJECT_BIN%\build.bat"
