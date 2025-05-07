@echo off
setlocal

:: 0. Asegurarnos de estar en la carpeta del script
cd /d "%~dp0"
echo [DEBUG] Directorio actual: %CD%

echo ===============================================
echo  Instalador de dependencias para Whisper (Windows)
echo ===============================================
echo.

:: 1. Verificar permisos de Administrador
net session >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Ejecuta este script como Administrador.
  pause
  exit /b
)

:: 2. Verificar e instalar Chocolatey
echo [INFO] Verificando Chocolatey...
choco -v >nul 2>&1 || (
  echo [INFO] Instalando Chocolatey...
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
  if errorlevel 1 (
    echo [ERROR] No se pudo instalar Chocolatey.
    pause
    exit /b
  )
  echo [INFO] Chocolatey instalado.
)
echo.

:: 3. Instalar ffmpeg
echo [INFO] Verificando ffmpeg...
ffmpeg -version >nul 2>&1 || (
  echo [INFO] Instalando ffmpeg...
  choco install ffmpeg -y
  if errorlevel 1 (
    echo [ERROR] No se pudo instalar ffmpeg.
    pause
    exit /b
  )
  echo [INFO] ffmpeg instalado.
)
echo.

:: 4. Verificar e instalar Python 3.10
echo [INFO] Verificando Python 3.x...
py -3 --version >nul 2>&1 || (
  echo [INFO] Instalando Python 3.10...
  choco install python --version=3.10.* -y
  if errorlevel 1 (
    echo [ERROR] No se pudo instalar Python 3.10.
    pause
    exit /b
  )
  echo [INFO] Python 3.10 instalado.
)
echo.

:: 5. Crear y activar entorno virtual
echo [INFO] Creando entorno virtual 'whisper_env' en %CD%...
set PYTHONPATH=
py -3 -m venv whisper_env
if errorlevel 1 (
  echo [ERROR] No se pudo crear el entorno virtual.
  pause
  exit /b
)
echo [INFO] Entorno virtual creado en "%CD%\whisper_env".
call whisper_env\Scripts\activate
echo.

:: 6. Actualizar pip
echo [INFO] Actualizando pip...
python -m pip install --upgrade pip
echo.

:: 7. Instalar PyTorch con CUDA 11.8
echo [INFO] Instalando torch/cu118 si hace falta...
pip show torch >nul 2>&1 || (
  pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118
)
echo [INFO] PyTorch instalado.
echo.

:: 8. Instalar openai-whisper y ffmpeg-python
echo [INFO] Instalando openai-whisper y ffmpeg-python…
pip show openai-whisper >nul 2>&1 || pip install openai-whisper --no-warn-script-location
pip show ffmpeg-python  >nul 2>&1 || pip install ffmpeg-python   --no-warn-script-location
echo.

:: 9. Pre-descargar modelo medium (en CPU)
echo [INFO] Descargando modelo medium de Whisper…
python -c "import whisper; whisper.load_model('medium')"
if errorlevel 1 (
  echo [ERROR] No se pudo descargar el modelo medium.
  pause
  exit /b
)
echo [INFO] Modelo medium descargado correctamente.
echo.

echo ===============================================
echo  Instalación completa. Ejecuta 02_transcriptor.bat
echo ===============================================
pause
exit /b
