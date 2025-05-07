:: 02_transcriptor.bat
@echo off
setlocal enabledelayedexpansion

:: -------------------------------------------------
:: 0. Ir al directorio donde está este script
:: -------------------------------------------------
cd /d %~dp0

echo ===============================================
echo  Transcriptor con Whisper (Windows)
echo ===============================================
echo.

:: -------------------------------------------------
:: 1. Activar entorno virtual
:: -------------------------------------------------
if not exist whisper_env (
    echo [ERROR] No encuentro la carpeta whisper_env. Ejecuta primero 00_instalar_dependencias.bat
    pause
    exit /b
)
call whisper_env\Scripts\activate

:: -------------------------------------------------
:: 2. Verificar ffmpeg y whisper
:: -------------------------------------------------
where ffmpeg  >nul 2>&1 || (
    echo [ERROR] ffmpeg no se encontró.
    pause
    exit /b
)
where whisper >nul 2>&1 || (
    echo [ERROR] El comando whisper no se encontró.
    pause
    exit /b
)

:: -------------------------------------------------
:: 3. Preparar carpetas
:: -------------------------------------------------
if not exist audios (
    mkdir audios
    echo [ERROR] Carpeta "audios\" creada. Pon tus archivos de audio ahí y vuelve a ejecutar.
    pause
    exit /b
)
if not exist transcripciones (
    mkdir transcripciones
)

echo ===============================================
echo  Iniciando transcripción de audios
echo ===============================================
echo.

:: -------------------------------------------------
:: 4. Procesar cada archivo en audios\*.* 
:: -------------------------------------------------
for %%F in (audios\*.*) do (
    echo -----------------------------------------------
    echo Procesando: %%~nxF

    :: 4.1 Convertir a WAV
    ffmpeg -y -i "%%F" temp.wav
    if errorlevel 1 (
        echo [ERROR] Error al convertir %%~nxF a WAV.
        goto :nextFile
    )

    :: 4.2 Transcribir con Whisper medium
    whisper temp.wav --model medium --output_format txt --output_dir transcripciones
    if errorlevel 1 (
        echo [ERROR] Falló la transcripción de %%~nxF.
        del temp.wav
        goto :nextFile
    )

    :: 4.3 Renombrar temp.txt a nombre_original.txt
    set "BASE=%%~nF"
    if exist "transcripciones\temp.txt" (
        if exist "transcripciones\!BASE!.txt" del /q "transcripciones\!BASE!.txt"
        move /y "transcripciones\temp.txt" "transcripciones\!BASE!.txt" >nul
        echo [INFO] Guardado: transcripciones\!BASE!.txt
    ) else (
        echo [WARNING] No se encontró temp.txt tras transcribir %%~nxF.
    )

    :: 4.4 Limpiar archivos temporales
    del /q temp.wav
    del /q transcripciones\temp.*

    :nextFile
    echo.
)

echo ===============================================
echo  Proceso completado.
echo ===============================================
pause
exit /b
