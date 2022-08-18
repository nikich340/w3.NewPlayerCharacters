@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

rem ---------------------------------------------------

:: auto execution of every step that is needed
SET PATCH_MODE=0

SET WCC_IMPORT_TEXTURES=1
SET WCC_COOK=1
SET WCC_REPACK_DLC=1
SET WCC_TEXTURECACHE=1

call "%DIR_PROJECT_BIN%\build.bat"
