@echo off
setlocal

REM Moverse al directorio donde esta el script
cd /d %~dp0

echo ===============================================
echo  Este script ELIMINA TODOS los archivos de:
echo    - audios
echo    - transcripciones
echo  Esta accion no se puede deshacer.
echo ===============================================
echo.

REM Pedir confirmacion
set /p CONFIRMA="¿Seguro que deseas continuar? (S/n) "

REM Si el usuario pulsa Enter sin escribir nada, se asume 'S'
if "%CONFIRMA%"=="" (
    set CONFIRMA=S
)

REM Si la respuesta es 'n' (o 'N') -> cancelar
if /i "%CONFIRMA%"=="n" (
    echo.
    echo [INFO] Operacion cancelada. No se elimino ningun archivo.
    pause
    exit /b
)

REM Si no es 'n', se interpreta como 'S' -> borrar
echo.
echo [INFO] Eliminando contenido de la carpeta 'audios'...
del /q "audios\*.*" 2>nul
for /d %%D in ("audios\*") do rd /s /q "%%~fD" 2>nul

echo [INFO] Eliminando contenido de la carpeta 'transcripciones'...
del /q "transcripciones\*.*" 2>nul
for /d %%D in ("transcripciones\*") do rd /s /q "%%~fD" 2>nul

echo.
echo [INFO] Se han eliminado todos los archivos de 'audios' y 'transcripciones'.
pause
exit /b
