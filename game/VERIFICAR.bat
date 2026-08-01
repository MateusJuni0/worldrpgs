@echo off
setlocal enabledelayedexpansion
title WorldRPGs - verificar tudo

rem ---------------------------------------------------------------
rem  Corre TODAS as verificacoes de uma vez.
rem
rem  Porque e que este ficheiro existe: os agentes comecaram a criar
rem  scripts de teste soltos (`--script ...`) que ninguem corria. Um
rem  teste que ninguem corre nao e um teste, e um ficheiro. Se criares
rem  outro, ACRESCENTA-O AQUI no mesmo acto.
rem ---------------------------------------------------------------

set "GODOT="
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
  for %%F in ("%%D\Godot_v*_win64_console.exe") do set "GODOT=%%F"
)
if not defined GODOT (
  for %%F in (godot.exe) do set "GODOT=%%~$PATH:F"
)
if not defined GODOT (
  echo Nao encontrei o Godot. Instala com: winget install GodotEngine.GodotEngine
  pause
  exit /b 1
)

set FALHOU=0

echo.
echo == 1/4  auto-teste principal (contra a spec e os catalogos) ==
"%GODOT%" --headless --audio-driver Dummy --path . scenes/selftest.tscn || set FALHOU=1

echo.
echo == 2/4  audio e icones das familias de armas ==
"%GODOT%" --headless --audio-driver Dummy --path . --script src/audio/delivery_self_test.gd || set FALHOU=1

echo.
echo == 3/4  abertura jogavel ==
"%GODOT%" --headless --audio-driver Dummy --path . --script src/ui/intro_selftest.gd || set FALHOU=1

echo.
echo == 4/4  guarda da spec (precisa de node) ==
pushd ..
node tools/check-coerencia.mjs || set FALHOU=1
popd

echo.
if "%FALHOU%"=="1" (
  echo ##  ALGUMA VERIFICACAO FALHOU  ##
) else (
  echo ##  TUDO PASSOU  ##
)
pause
