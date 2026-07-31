@echo off
setlocal enabledelayedexpansion
title WorldRPGs - prototipo da fatia 1

rem ---------------------------------------------------------------
rem  Duplo clique neste ficheiro e o jogo abre. Mais nada e preciso.
rem  Se quiseres a arena limpa de combate em vez da zona toda,
rem  usa JOGAR-ARENA.bat.
rem ---------------------------------------------------------------

set "GODOT="

rem 1. Onde o winget instala.
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
  for %%F in ("%%D\Godot_v*_win64.exe") do (
    echo %%~nxF | find /i "console" >nul || set "GODOT=%%F"
  )
)

rem 2. Godot no PATH.
if not defined GODOT (
  for /f "delims=" %%G in ('where godot 2^>nul') do set "GODOT=%%G"
)

rem 3. Ao lado deste ficheiro.
if not defined GODOT (
  for %%F in ("%~dp0Godot_v*_win64.exe") do set "GODOT=%%F"
)

if not defined GODOT (
  echo.
  echo  Nao encontrei o Godot nesta maquina.
  echo.
  echo  Instala-o com este comando numa janela de terminal:
  echo      winget install --id=GodotEngine.GodotEngine
  echo.
  echo  ou poe o Godot_v4.7.1-stable_win64.exe nesta mesma pasta.
  echo.
  pause
  exit /b 1
)

rem O ponto no fim de "%~dp0." nao e engano: %~dp0 acaba em barra invertida,
rem que escaparia a aspa de fecho e engoliria o resto da linha de comandos.
echo A abrir com: !GODOT!
"!GODOT!" --path "%~dp0." --rendering-method mobile
if errorlevel 1 pause
