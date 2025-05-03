@echo off
setlocal

echo ===============================================
echo  Instalador de dependencias para Whisper (Windows)
echo ===============================================
echo.

:: -------------------------------------------------
:: 1. Verificar permisos de Administrador
:: -------------------------------------------------
net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Este script debe ejecutarse como Administrador.
    echo Haz clic derecho en este archivo y selecciona 'Ejecutar como Administrador'.
    pause
    exit /b
)

:: -------------------------------------------------
:: 2. Verificar e Instalar Chocolatey
:: -------------------------------------------------
echo [INFO] Verificando Chocolatey...
choco -v >nul 2>&1
if errorlevel 1 (
    echo [INFO] Chocolatey no esta instalado. Instalando Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar Chocolatey.
        pause
        exit /b
    )
    echo [INFO] Chocolatey instalado correctamente.
) else (
    echo [INFO] Chocolatey ya esta instalado.
)
echo.

:: -------------------------------------------------
:: 3. Verificar e Instalar FFmpeg
:: -------------------------------------------------
echo [INFO] Verificando ffmpeg...
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo [INFO] ffmpeg no esta instalado. Instalando ffmpeg...
    choco install ffmpeg -y
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar ffmpeg.
        pause
        exit /b
    )
    echo [INFO] ffmpeg instalado correctamente.
) else (
    echo [INFO] ffmpeg ya esta instalado.
)
echo.

:: -------------------------------------------------
:: 4. Verificar e Instalar Python
:: -------------------------------------------------
echo [INFO] Verificando instalacion de Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Python no esta instalado. Instalando Python...
    choco install python -y
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar Python.
        pause
        exit /b
    )
    echo [INFO] Python instalado correctamente.
) else (
    echo [INFO] Python ya esta instalado.
)
echo.

:: -------------------------------------------------
:: 5. Crear (si no existe) y Activar el Entorno Virtual
:: -------------------------------------------------
if not exist whisper_env (
    echo [INFO] Creando entorno virtual whisper_env...
    python -m venv whisper_env
    if errorlevel 1 (
        echo [ERROR] No se pudo crear el entorno virtual.
        pause
        exit /b
    )
) else (
    echo [INFO] El entorno virtual whisper_env ya existe.
)

echo [INFO] Activando entorno virtual...
call whisper_env\Scripts\activate
echo.

:: -------------------------------------------------
:: 6. Actualizar pip
:: -------------------------------------------------
echo [INFO] Actualizando pip...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo [WARNING] No se pudo actualizar pip, se continuara de todas formas...
) else (
    echo [INFO] pip actualizado correctamente.
)
echo.

:: -------------------------------------------------
:: 7. Verificar PyTorch con CUDA
:: -------------------------------------------------
echo [INFO] Verificando PyTorch con CUDA...
pip show torch >nul 2>&1
if errorlevel 1 (
    echo [INFO] PyTorch con CUDA no esta instalado. Instalando...
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar PyTorch con CUDA. Revisa tu conexion o la version de CUDA.
        pause
        exit /b
    )
    echo [INFO] PyTorch con CUDA instalado correctamente.
) else (
    echo [INFO] PyTorch con CUDA ya esta instalado o detectado en el entorno.
)
echo.

:: -------------------------------------------------
:: 8. Verificar e Instalar Whisper
:: -------------------------------------------------
echo [INFO] Verificando instalacion de Whisper...
whisper --help >nul 2>&1
if errorlevel 1 (
    echo [INFO] Whisper no esta instalado. Revisando con pip...
    pip show openai-whisper >nul 2>&1
    if errorlevel 1 (
        echo [INFO] Instalando Whisper y ffmpeg-python...
        pip install openai-whisper ffmpeg-python
        if errorlevel 1 (
            echo [ERROR] No se pudo instalar Whisper.
            pause
            exit /b
        )
        echo [INFO] Whisper instalado correctamente.
    ) else (
        echo [INFO] Whisper figura instalado segun pip.
        echo [INFO] Si whisper --help no funciona, cierra y abre otra terminal con el entorno activo.
    )
) else (
    echo [INFO] Whisper ya esta instalado en el entorno virtual.
)
echo.

:: -------------------------------------------------
:: 9. Descargar Modelo Whisper medium
:: -------------------------------------------------
echo [INFO] Descargando el modelo medium de Whisper...
python -c "import whisper; whisper.load_model('medium')"
if errorlevel 1 (
    echo [ERROR] No se pudo descargar el modelo medium.
    pause
    exit /b
)
echo [INFO] Modelo medium descargado correctamente.
echo.

:: -------------------------------------------------
:: 10. Mensaje Final
:: -------------------------------------------------
echo ===============================================
echo  Instalacion completa
echo  Ahora puedes ejecutar 01_transcriptor.bat para transcribir audios.
echo ===============================================
pause
exit /b
