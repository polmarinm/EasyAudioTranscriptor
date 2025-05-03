@echo off
setlocal

REM -------------------------------------------------
REM 1. Moverse al directorio donde esta este script
REM -------------------------------------------------
cd /d %~dp0

echo ===============================================
echo  Activando entorno virtual whisper_env...
echo ===============================================
call whisper_env\Scripts\activate || (
    echo [ERROR] No se pudo activar el entorno virtual.
    pause
    exit /b
)

REM -------------------------------------------------
REM 2. Verificar carpetas audios y transcripciones
REM -------------------------------------------------
if not exist audios (
    echo [ERROR] La carpeta 'audios' no existe.
    pause
    exit /b
)

if not exist transcripciones (
    echo [INFO] Creando carpeta 'transcripciones'...
    mkdir transcripciones
)

echo ===============================================
echo  Iniciando proceso de conversion y transcripcion
echo ===============================================

REM -------------------------------------------------
REM 3. Recorrer los archivos de la carpeta audios
REM -------------------------------------------------
for %%F in (audios\*.*) do call :PROCESS_FILE "%%F"

echo.
echo ===============================================
echo  Proceso completado
echo ===============================================
pause
exit /b

REM -------------------------------------------------
REM SUBRUTINA: PROCESS_FILE
REM -------------------------------------------------
:PROCESS_FILE
set "INPUT=%~1"
set "BASE=%~n1"

echo -----------------------------------------------
echo Procesando archivo: %INPUT%

REM 3.1 - Convertir a WAV con ffmpeg
ffmpeg -y -i "%INPUT%" "temp.wav"
if errorlevel 1 (
    echo [ERROR] Fallo la conversion de %INPUT%.
    goto :EOF
)

REM 3.2 - Transcribir con Whisper (modelo medium), solo formato .txt
whisper temp.wav --output_dir transcripciones --model medium --output_format txt
if errorlevel 1 (
    echo [ERROR] Fallo la transcripcion de %INPUT%.
    goto :CLEANUP
)

REM 3.3 - Renombrar el archivo transcrito 'temp.txt' a '%BASE%.txt'
REM        y sobrescribir si ya existe
if exist "transcripciones\%BASE%.txt" del "transcripciones\%BASE%.txt"
if exist "transcripciones\temp.txt" (
    ren "transcripciones\temp.txt" "%BASE%.txt"
    echo [INFO] Se guardo la transcripcion en transcripciones\%BASE%.txt
) else (
    echo [WARNING] No se encontro 'transcripciones\\temp.txt'
)

:CLEANUP
REM 3.4 - Eliminar el WAV temporal
if exist temp.wav del temp.wav

REM 3.5 - Eliminar archivos residuales (p.ej. temp.*) por si tu version de Whisper crea algo mas
if exist "transcripciones\temp.*" del "transcripciones\temp.*"
if exist "transcripciones\temp" del "transcripciones\temp"

goto :EOF
