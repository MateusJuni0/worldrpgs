@echo off
setlocal enabledelayedexpansion
title WorldRPGs - arena de combate

rem ---------------------------------------------------------------
rem  Arena limpa: um lanceiro e um brutamontes, sem floresta a meio.
rem  E o sitio para sentir o combate e afinar numeros.
rem ---------------------------------------------------------------

set "GODOT="
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
  for %%F in ("%%D\Godot_v*_win64.exe") do (
    echo %%~nxF | find /i "console" >nul || set "GODOT=%%F"
  )
)
if not defined GODOT (
  for /f "delims=" %%G in ('where godot 2^>nul') do set "GODOT=%%G"
)
if not defined GODOT (
  for %%F in ("%~dp0Godot_v*_win64.exe") do set "GODOT=%%F"
)

if not defined GODOT (
  echo Nao encontrei o Godot. Corre primeiro: winget install --id=GodotEngine.GodotEngine
  pause
  exit /b 1
)

"!GODOT!" --path "%~dp0" --rendering-method mobile -- --scene=combat
if errorlevel 1 pause
