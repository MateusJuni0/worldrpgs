@echo off
setlocal enabledelayedexpansion
title WorldRPGs
cd /d "%~dp0"

rem ---------------------------------------------------------------
rem  O lancador do jogo. Faz tres coisas, por esta ordem:
rem    1. ve se ha versao nova no GitHub e traz
rem    2. reimporta os assets se algo mudou
rem    3. abre o jogo
rem
rem  E o ficheiro para onde o atalho do ambiente de trabalho aponta.
rem  Cria o atalho com INSTALAR-ATALHO.bat (uma vez so).
rem ---------------------------------------------------------------

echo.
echo   W O R L D R P G S
echo   -----------------
echo.

rem --- 1. actualizar -----------------------------------------------
where git >nul 2>&1
if errorlevel 1 (
  echo   [!] Sem git instalado - salto a actualizacao.
  goto :abrir
)

echo   A ver se ha novidades...
git fetch --quiet origin main 2>nul

for /f %%i in ('git rev-parse HEAD 2^>nul') do set "LOCAL=%%i"
for /f %%i in ('git rev-parse origin/main 2^>nul') do set "REMOTO=%%i"

if "!LOCAL!"=="!REMOTO!" (
  echo   Ja estas na versao mais recente.
  goto :abrir
)

rem Se houver trabalho por guardar, NAO destruir nada.
git diff --quiet 2>nul
if errorlevel 1 (
  echo.
  echo   [!] Tens alteracoes por guardar. Nao actualizo para nao as perder.
  echo       Guarda-as ^(git commit^) ou desfa-las, e volta a correr.
  echo.
  goto :abrir
)

for /f %%i in ('git rev-list --count HEAD..origin/main 2^>nul') do set "QUANTOS=%%i"
echo   Ha !QUANTOS! actualizacao^(oes^). A trazer...
git merge --ff-only origin/main
if errorlevel 1 (
  echo   [!] Nao consegui actualizar sem conflito. Abro a versao que tens.
  goto :abrir
)
echo   Actualizado.
set "REIMPORTAR=1"

:abrir
rem --- 2. encontrar o Godot ----------------------------------------
set "GODOT="
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
  for %%F in ("%%D\Godot_v*_win64.exe") do (
    echo %%~nxF | find /i "console" >nul || set "GODOT=%%F"
  )
)
if not defined GODOT for %%F in (godot.exe) do set "GODOT=%%~$PATH:F"

if not defined GODOT (
  echo.
  echo   [X] Nao encontrei o Godot.
  echo       Instala com:  winget install GodotEngine.GodotEngine
  echo.
  pause
  exit /b 1
)

rem --- 3. reimportar se veio codigo novo ---------------------------
if defined REIMPORTAR (
  echo   A preparar os assets novos ^(so desta vez^)...
  "%GODOT%" --headless --audio-driver Dummy --path game --import >nul 2>&1
)

echo   A abrir o jogo...
echo.
start "" "%GODOT%" --path "%~dp0game" --rendering-method mobile
exit /b 0
