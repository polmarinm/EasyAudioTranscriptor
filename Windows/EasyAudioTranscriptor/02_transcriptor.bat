@echo off
setlocal enabledelayedexpansion

:: 0. Ir al directorio del script
cd /d %~dp0

echo ===============================================
echo  Transcriptor GPU con Insanely-Fast-Whisper
echo ===============================================
echo.

:: 1. Activar entorno virtual
if not exist whisper_env (
    echo [ERROR] No encuentro la carpeta whisper_env. Ejecuta primero 00_instalar_dependencias.bat
    pause
    exit /b
)
call whisper_env\Scripts\activate

:: 2. Verificar CUDA runtime
where cublas64_12.dll >nul 2>&1
if errorlevel 1 (
    echo [ERROR] cublas64_12.dll no se encuentra en el PATH.
    echo Asegurate de cerrar la sesion o reiniciar CMD tras la instalacion de CUDA Toolkit.
    pause
    exit /b
)

:: 3. Verificar ffmpeg
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo [ERROR] ffmpeg no se encontro.
    pause
    exit /b
)

:: 4. Preparar carpetas
if not exist audios (
    mkdir audios
    echo [ERROR] Carpeta "audios\" creada. Pon tus archivos ahi y vuelve a ejecutar.
    pause
    exit /b
)
if not exist transcripciones mkdir transcripciones

echo ===============================================
echo  Iniciando transcripcion de audios
echo ===============================================
echo.

:: 5. Crear script Python temporal
set "PYFILE=%TEMP%\transcribe_gpu.py"
del "%PYFILE%" 2>nul
> "%PYFILE%" echo import sys
>>"%PYFILE%" echo from faster_whisper import WhisperModel
>>"%PYFILE%" echo model = WhisperModel("distil-large-v2", device="cuda")
>>"%PYFILE%" echo segments, _ = model.transcribe(sys.argv[1], beam_size=5)
>>"%PYFILE%" echo out = sys.argv[2]
>>"%PYFILE%" echo with open(out, "w", encoding="utf-8") as f:
>>"%PYFILE%" echo     for seg in segments: f.write(seg.text.strip() + "\n")

:: 6. Procesar cada audio
for %%F in (audios\*.*) do (
    echo -----------------------------------------------
    echo Procesando: %%~nxF

    ffmpeg -y -i "%%F" temp.wav
    if errorlevel 1 (
        echo [ERROR] Error al convertir %%~nxF
        goto :nextLoop
    )

    python "%PYFILE%" "temp.wav" "transcripciones/%%~nF.txt"
    if errorlevel 1 (
        echo [ERROR] Fallo la transcripcion de %%~nxF
        del temp.wav
        goto :nextLoop
    )

    del temp.wav
    echo [INFO] Guardado: transcripciones\%%~nF.txt

    :nextLoop
    echo.
)

:: 7. Borrar script Python temporal
del "%PYFILE%"

echo ===============================================
echo  Proceso completado.
echo ===============================================
pause
exit /b
