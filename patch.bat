@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title RPG Detective Korean Patcher

REM ------------------------------------------------------------------
REM patch.bat
REM - Copies patch_files\locate.data to this folder (overwrite)
REM - Patches RPGDetecive.pck by overriding:
REM     res://scene/items/i_searcher_input.gdc
REM     res://scene/items/i_searcher_input.gd.remap
REM ------------------------------------------------------------------

set "BASE=%~dp0"
set "TOOLS=%BASE%tools"
set "PCK=%BASE%RPGDetecive.pck"
set "PATCH_SRC=%BASE%patch_files"

set "GDRE=%TOOLS%\gdre_tools.exe"

echo [1/3] locate.data 덮어쓰는 중...
if not exist "%PATCH_SRC%\locate.data" (
  echo ERROR: 파일을 찾을 수 없습니다: "%PATCH_SRC%\locate.data"
  exit /b 1
)
copy /Y "%PATCH_SRC%\locate.data" "%BASE%locate.data" >nul
if errorlevel 1 (
  echo ERROR: locate.data 복사에 실패했습니다
  exit /b 1
)

if not exist "%PATCH_SRC%\i_searcher_input.gdc" (
  echo ERROR: 파일을 찾을 수 없습니다: "%PATCH_SRC%\i_searcher_input.gdc"
  goto :END
)
if not exist "%PATCH_SRC%\i_searcher_input.gd.remap" (
  echo ERROR: 파일을 찾을 수 없습니다: "%PATCH_SRC%\i_searcher_input.gd.remap"
  goto :END
)

echo [2/3] 원본 PCK 백업 생성 중...
copy "%PCK%" "%PCK%.backup" >nul

echo [3/3] GDRE Tools를 통해 PCK 패치 중...
if not exist "%GDRE%" (
  echo ERROR: 파일을 찾을 수 없습니다: "%GDRE%"
  goto :END
)
if not exist "%PCK%" (
  echo ERROR: 파일을 찾을 수 없습니다: "%PCK%"
  goto :END
)

"%GDRE%" --headless --pck-patch="%PCK%.backup" ^
  --patch-file="%PATCH_SRC%\i_searcher_input.gdc"="res://scene/items/i_searcher_input.gdc" ^
  --patch-file="%PATCH_SRC%\i_searcher_input.gd.remap"="res://scene/items/i_searcher_input.gd.remap" ^
  --patch-file="%PATCH_SRC%\i_party.tscn.remap"="res://scene/items/i_party.tscn.remap" ^
  --patch-file="%PATCH_SRC%\_TitleScene.tscn.remap"="res://scene/canvas/_TitleScene.tscn.remap" ^
  --patch-file="%PATCH_SRC%\export-1fb51089a4687ce6b57b79f41444e4c5-i_party.scn"="res://.godot/exported/133200997/export-1fb51089a4687ce6b57b79f41444e4c5-i_party.scn" ^
  --patch-file="%PATCH_SRC%\export-6859bfc9ba6f80c10b573329854cf86a-_TitleScene.scn"="res://.godot/exported/133200997/export-6859bfc9ba6f80c10b573329854cf86a-_TitleScene.scn" ^
  --patch-file="%PATCH_SRC%\HakgyoansimMoheomgaB.ttf-df5f1dab6abb0d40529d4932a731861b.fontdata"="res://.godot/imported/HakgyoansimMoheomgaB.ttf-df5f1dab6abb0d40529d4932a731861b.fontdata" ^
  --patch-file="%PATCH_SRC%\HakgyoansimMoheomgaB.ttf.import"="res://data/font/HakgyoansimMoheomgaB.ttf.import" ^
  --output="%PCK%"


set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo ERROR: gdre_tools.exe failed with exit code %RC%
  goto :END
)

echo 패치 완료! "%PCK%"이 업데이트되었습니다.

:END
echo.
echo 패치가 완료되었습니다. 문제가 발생하면 "%PCK%.backup"에서 원본 PCK를 복원하세요.
echo 아무 키나 눌러서 종료하세요...
pause >nul
exit /b 0