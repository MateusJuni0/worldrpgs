@echo off
setlocal
title WorldRPGs - instalar atalho
cd /d "%~dp0"

rem ---------------------------------------------------------------
rem  Corre isto UMA VEZ. Poe um atalho "WorldRPGs" no ambiente de
rem  trabalho que actualiza e abre o jogo com um duplo clique.
rem  Funciona em qualquer PC que tenha o repositorio clonado — nao
rem  tem caminhos fixos la dentro.
rem ---------------------------------------------------------------

echo.
echo   A criar o atalho no ambiente de trabalho...

rem Gera o icone a partir do SVG do jogo, se ainda nao existir.
if not exist "%~dp0game\icon.ico" (
  if exist "%~dp0game\icon.svg" (
    echo   ^(sem icone .ico - o atalho usa o icone do Godot^)
  )
)

set "ALVO=%~dp0JOGAR-WORLDRPGS.bat"
set "ICONE=%~dp0game\icon.ico"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ws = New-Object -ComObject WScript.Shell;" ^
  "$lnk = $ws.CreateShortcut([IO.Path]::Combine($ws.SpecialFolders('Desktop'),'WorldRPGs.lnk'));" ^
  "$lnk.TargetPath = '%ALVO%';" ^
  "$lnk.WorkingDirectory = '%~dp0';" ^
  "$lnk.Description = 'WorldRPGs - actualiza e abre o jogo';" ^
  "if (Test-Path '%ICONE%') { $lnk.IconLocation = '%ICONE%' };" ^
  "$lnk.Save();" ^
  "Write-Host '   Atalho criado: ' ([IO.Path]::Combine($ws.SpecialFolders('Desktop'),'WorldRPGs.lnk'))"

echo.
echo   Pronto. Ja tens o WorldRPGs no ambiente de trabalho.
echo   Duplo clique: actualiza sozinho e abre o jogo.
echo.
pause
