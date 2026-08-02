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
rem
rem  !! E DEVOLVE O CODIGO DE ERRO. Ate 02-08-2026 este ficheiro
rem  imprimia "ALGUMA VERIFICACAO FALHOU" e saia com 0 -- quem o
rem  corresse por script via sempre verde. Uma prova que mente e pior
rem  que nenhuma prova.
rem
rem  Uso: VERIFICAR.bat            (humano, faz pausa no fim)
rem       VERIFICAR.bat --rapido   (salta o que demora minutos)
rem       VERIFICAR.bat --sem-pausa (para correr dentro de um script)
rem ---------------------------------------------------------------

set "RAPIDO=0"
set "PAUSA=1"
for %%A in (%*) do (
  if "%%A"=="--rapido" set "RAPIDO=1"
  if "%%A"=="--sem-pausa" set "PAUSA=0"
)

set "GODOT="
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
  for %%F in ("%%D\Godot_v*_win64_console.exe") do set "GODOT=%%F"
)
if not defined GODOT (
  for %%F in (godot.exe) do set "GODOT=%%~$PATH:F"
)
if not defined GODOT (
  echo Nao encontrei o Godot. Instala com: winget install GodotEngine.GodotEngine
  if "!PAUSA!"=="1" pause
  exit /b 1
)

set FALHOU=0

echo.
echo == 1/13  auto-teste principal (contra a spec e os catalogos) ==
"%GODOT%" --headless --audio-driver Dummy --path . scenes/selftest.tscn || set FALHOU=1

echo.
echo == 2/13  audio e icones das familias de armas ==
"%GODOT%" --headless --audio-driver Dummy --path . --script src/audio/delivery_self_test.gd || set FALHOU=1

echo.
echo == 3/13  abertura jogavel ==
"%GODOT%" --headless --audio-driver Dummy --path . --script src/ui/intro_selftest.gd || set FALHOU=1

echo.
echo == 4/13  arranque real: criar personagem e entrar no jogo ==
"%GODOT%" --headless --audio-driver Dummy --path . scenes/repro-inicio.tscn || set FALHOU=1

echo.
echo == 5/13  descanso real na fogueira (save isolado) ==
set "ORIGINAL_APPDATA=%APPDATA%"
set "ORIGINAL_WORLDRPGS_TEST_USER_ROOT=%WORLDRPGS_TEST_USER_ROOT%"
set "BONFIRE_TEST_PARENT=%TEMP%\worldrpgs-verificar"
for %%I in ("!BONFIRE_TEST_PARENT!") do set "BONFIRE_TEST_PARENT=%%~fI"
set "BONFIRE_TEST_APPDATA=!BONFIRE_TEST_PARENT!\bonfire-!RANDOM!-!RANDOM!"
2>nul md "!BONFIRE_TEST_APPDATA!"
if errorlevel 1 (
  echo Nao foi possivel criar o APPDATA temporario da prova da fogueira.
  set FALHOU=1
) else (
  set "APPDATA=!BONFIRE_TEST_APPDATA!"
  set "WORLDRPGS_TEST_USER_ROOT=!BONFIRE_TEST_APPDATA!"
  "%GODOT%" --headless --audio-driver Dummy --path . src/progression/bonfire_gameplay_repro.tscn || set FALHOU=1
  set "APPDATA=!ORIGINAL_APPDATA!"
  set "WORLDRPGS_TEST_USER_ROOT=!ORIGINAL_WORLDRPGS_TEST_USER_ROOT!"
  if exist "!BONFIRE_TEST_APPDATA!\" rd /s /q "!BONFIRE_TEST_APPDATA!"
  2>nul rd "!BONFIRE_TEST_PARENT!"
)

echo.
echo == 6/13  melhorias de armas ==
"%GODOT%" --headless --audio-driver Dummy --path . --script src/weapons/weapon_progression_selftest.gd || set FALHOU=1

echo.
echo == 7/13  camada de rede (protocolo, interpolacao, latencia) ==
"%GODOT%" --headless --audio-driver Dummy --path . --script src/net/net_selftest.gd || set FALHOU=1

rem ---------------------------------------------------------------
rem  ** Daqui para baixo nao sao contratos, e JOGAR. Um contrato verde
rem  nunca apanhou o personagem preto, nem o murro com a espada na
rem  mao, nem a fogueira que nao gravava. Isto apanha.
rem ---------------------------------------------------------------

echo.
echo == 8/13  sessao de jogo: nasce, equipa, bate, mata, bebe, descansa ==
"%GODOT%" --headless --audio-driver Dummy --path . scenes/sessao-de-jogo.tscn || set FALHOU=1

echo.
if "!RAPIDO!"=="1" (
  echo == 9/13  percurso ate ao chefe  [SALTADO por --rapido] ==
) else (
  echo == 9/13  percurso: ANDA de ponta a ponta e chega ao chefe ==
  "%GODOT%" --headless --audio-driver Dummy --path . scenes/percurso.tscn || set FALHOU=1
)

echo.
echo == 10/13  o chefe cai: luta inteira, 1950 PV, sem baixar a vida dele ==
set "VORGAR_PARENT=%TEMP%\worldrpgs-verificar"
for %%I in ("!VORGAR_PARENT!") do set "VORGAR_PARENT=%%~fI"
set "VORGAR_APPDATA=!VORGAR_PARENT!\vorgar-!RANDOM!-!RANDOM!"
2>nul md "!VORGAR_APPDATA!"
if errorlevel 1 (
  echo Nao foi possivel criar o APPDATA temporario da prova do chefe.
  set FALHOU=1
) else (
  set "APPDATA=!VORGAR_APPDATA!"
  set "WORLDRPGS_TEST_USER_ROOT=!VORGAR_APPDATA!"
  "%GODOT%" --headless --audio-driver Dummy --path . scenes/arena_vorgar.tscn -- --scene=vorgar --vorgar-full-fight-proof || set FALHOU=1
  set "APPDATA=!ORIGINAL_APPDATA!"
  set "WORLDRPGS_TEST_USER_ROOT=!ORIGINAL_WORLDRPGS_TEST_USER_ROOT!"
  if exist "!VORGAR_APPDATA!\" rd /s /q "!VORGAR_APPDATA!"
  2>nul rd "!VORGAR_PARENT!"
)

echo.
echo == 11/13  codigo que o jogo nunca chama (orfaos) ==
pushd ..
node tools/orfaos.mjs || set FALHOU=1
popd

echo.
echo == 12/13  spec que o codigo nunca implementou ==
pushd ..
node tools/cobertura-spec.mjs || set FALHOU=1
popd

echo.
echo == 13/13  guarda da spec (precisa de node) ==
pushd ..
node tools/check-coerencia.mjs || set FALHOU=1
popd

echo.
if "%FALHOU%"=="1" (
  echo ##  ALGUMA VERIFICACAO FALHOU  ##
) else (
  echo ##  TUDO PASSOU  ##
)
if "!PAUSA!"=="1" pause
exit /b %FALHOU%
