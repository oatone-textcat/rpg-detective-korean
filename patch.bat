@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
title RPG Detective Korean Patcher

:: Enable ANSI colors
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "C_RESET=%ESC%[0m"
set "C_INFO=%ESC%[36m"
set "C_OK=%ESC%[32m"
set "C_WARN=%ESC%[33m"
set "C_ERR=%ESC%[31m"
set "C_STEP=%ESC%[35m"
set "C_TITLE=%ESC%[97m"

REM ------------------------------------------------------------------
REM patch.bat
REM - Copies patch_files\locate.data to this folder (overwrite)
REM - Patches RPGDetecive.pck by overriding/adding:
REM     res://scene/items/i_searcher_input.gdc
REM     res://scene/items/i_searcher_input.gd.remap
REM     res://scene/items/i_party.tscn.remap
REM     res://.godot/exported/133200997/export-1fb51089a4687ce6b57b79f41444e4c5-i_party.scn
REM     res://scene/canvas/_TitleScene.tscn.remap
REM     res://.godot/exported/133200997/export-6859bfc9ba6f80c10b573329854cf86a-_TitleScene.scn
REM     res://data/font/HakgyoansimMoheomgaB.ttf.import
REM     res://.godot/imported/HakgyoansimMoheomgaB.ttf-df5f1dab6abb0d40529d4932a731861b.fontdata
REM ------------------------------------------------------------------

set "BASE=%~dp0"
set "TOOLS=%BASE%tools"
set "PCK=%BASE%RPGDetecive.pck"

set "PATCH_SRC=%BASE%patch_files"

set "GDRE=%TOOLS%\gdre_tools.exe"

echo.
echo %C_TITLE%======================================================%C_RESET%
echo %C_TITLE%*     길드 탐구단에 어서 오세요! 비공식 한글 패치    *%C_RESET%
echo %C_TITLE%*                                                    *%C_RESET%
echo %C_TITLE%*                 제작: 팀 글냥이                    *%C_RESET%
echo %C_TITLE%*                  번역: Pixel4a                     *%C_RESET%
echo %C_TITLE%======================================================%C_RESET%
echo.

echo %C_INFO%[1/3]%C_RESET% locate.data 덮어쓰는 중...
if not exist "%PATCH_SRC%\locate.data" (
  echo %C_ERR%ERROR: 파일을 찾을 수 없습니다: "%PATCH_SRC%\locate.data"%C_RESET%
  exit /b 1
)
copy /Y "%PATCH_SRC%\locate.data" "%BASE%locate.data" >nul
if errorlevel 1 (
  echo %C_ERR%ERROR: locate.data 복사에 실패했습니다%C_RESET%
  exit /b 1
)

if not exist "%PATCH_SRC%\i_searcher_input.gdc" (
  echo %C_ERR%ERROR: 파일을 찾을 수 없습니다: "%PATCH_SRC%\i_searcher_input.gdc"%C_RESET%
  goto :END
)
if not exist "%PATCH_SRC%\i_searcher_input.gd.remap" (
  echo %C_ERR%ERROR: 파일을 찾을 수 없습니다: "%PATCH_SRC%\i_searcher_input.gd.remap"%C_RESET%
  goto :END
)

echo %C_OK%locate.data 적용 완료%C_RESET%

echo %C_INFO%[2/3]%C_RESET% 원본 PCK 백업 생성 중...
copy "%PCK%" "%PCK%.backup" >nul

echo %C_OK%백업 생성 완료: "%PCK%.backup"%C_RESET%

echo %C_INFO%[3/3]%C_RESET% GDRE Tools를 통해 PCK 패치 중...
echo %C_WARN%이 작업은 조금 시간이 소요될 수 있습니다.%C_RESET%
echo.

if not exist "%GDRE%" (
  echo %C_ERR%ERROR: 파일을 찾을 수 없습니다: "%GDRE%"%C_RESET%
  goto :END
)
if not exist "%PCK%" (
  echo %C_ERR%ERROR: 파일을 찾을 수 없습니다: "%PCK%"%C_RESET%
  goto :END
)

"%GDRE%" --headless --pck-patch="%PCK%.backup" ^
  --patch-file="%PATCH_SRC%\i_searcher_input.gdc"="res://scene/items/i_searcher_input.gdc" ^
  --patch-file="%PATCH_SRC%\i_searcher_input.gd.remap"="res://scene/items/i_searcher_input.gd.remap" ^
  --patch-file="%PATCH_SRC%\i_party.tscn.remap"="res://scene/items/i_party.tscn.remap" ^
  --patch-file="%PATCH_SRC%\_TitleScene.tscn.remap"="res://scene/canvas/_TitleScene.tscn.remap" ^
  --patch-file="%PATCH_SRC%\i_end_img.tscn.remap"="res://scene/items/i_end_img.tscn.remap" ^
  --patch-file="%PATCH_SRC%\export-1fb51089a4687ce6b57b79f41444e4c5-i_party.scn"="res://.godot/exported/133200997/export-1fb51089a4687ce6b57b79f41444e4c5-i_party.scn" ^
  --patch-file="%PATCH_SRC%\export-6859bfc9ba6f80c10b573329854cf86a-_TitleScene.scn"="res://.godot/exported/133200997/export-6859bfc9ba6f80c10b573329854cf86a-_TitleScene.scn" ^
  --patch-file="%PATCH_SRC%\export-8b47332452111aec29a4cfcd23ec4598-i_end_img.scn"="res://.godot/exported/133200997/export-8b47332452111aec29a4cfcd23ec4598-i_end_img.scn" ^
  --patch-file="%PATCH_SRC%\HakgyoansimMoheomgaB.ttf-df5f1dab6abb0d40529d4932a731861b.fontdata"="res://.godot/imported/HakgyoansimMoheomgaB.ttf-df5f1dab6abb0d40529d4932a731861b.fontdata" ^
  --patch-file="%PATCH_SRC%\HakgyoansimMoheomgaB.ttf.import"="res://data/font/HakgyoansimMoheomgaB.ttf.import" ^
  --output="%PCK%"


set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo %C_ERR%ERROR: gdre_tools.exe failed with exit code %RC%%C_RESET%
  goto :END
)

echo.
echo %C_OK%==============================================%C_RESET%
echo %C_OK%        패치가 성공적으로 완료되었습니다!        %C_RESET%
echo %C_OK%==============================================%C_RESET%
echo.
echo 문제가 발생할 경우 아래 파일로 복원하세요:
echo   %C_WARN%%PCK%.backup%C_RESET%
echo.

:END
echo 아무 키나 눌러 종료합니다...
pause >nul
exit /b 0