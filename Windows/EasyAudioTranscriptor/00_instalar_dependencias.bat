@echo off
setlocal

echo ===============================================
echo  Instalador de dependencias para Insanely-Fast-Whisper (Windows)
echo ===============================================
echo.

:: 1. Verificar permisos de Administrador
net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Ejecuta este script como Administrador.
    pause & exit /b
)

:: 2. Verificar e instalar Chocolatey
echo [INFO] Verificando Chocolatey...
choco -v >nul 2>&1
if errorlevel 1 (
    echo [INFO] Instalando Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar Chocolatey.
        pause & exit /b
    )
    echo [INFO] Chocolatey instalado.
) else (
    echo [INFO] Chocolatey ya está instalado.
)
echo.

:: 3. Verificar e instalar ffmpeg
echo [INFO] Verificando ffmpeg...
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Instalando ffmpeg...
    choco install ffmpeg -y
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar ffmpeg.
        pause & exit /b
    )
    echo [INFO] ffmpeg instalado.
) else (
    echo [INFO] ffmpeg ya está instalado.
)
echo.

:: 4. Verificar e instalar Python
echo [INFO] Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Instalando Python...
    choco install python -y
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar Python.
        pause & exit /b
    )
    echo [INFO] Python instalado.
) else (
    echo [INFO] Python ya está instalado.
)
echo.

:: 5. Crear y activar entorno virtual
if not exist whisper_env (
    echo [INFO] Creando entorno virtual...
    python -m venv whisper_env
    if errorlevel 1 (
        echo [ERROR] No se pudo crear el entorno virtual.
        pause & exit /b
    )
) else (
    echo [INFO] Entorno virtual ya existe.
)
echo [INFO] Activando entorno virtual...
call whisper_env\Scripts\activate
echo.

:: 6. Actualizar pip
echo [INFO] Actualizando pip...
python -m pip install --upgrade pip
echo.

:: 7. Instalar PyTorch con CUDA
echo [INFO] Verificando PyTorch con CUDA...
pip show torch >nul 2>&1
if errorlevel 1 (
    echo [INFO] Instalando torch-cu118...
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar PyTorch CUDA.
        pause & exit /b
    )
    echo [INFO] PyTorch con CUDA instalado.
) else (
    echo [INFO] PyTorch con CUDA ya está instalado.
)
echo.

:: 8. Instalar faster-whisper-cli y ffmpeg-python
echo [INFO] Instalando faster-whisper-cli y ffmpeg-python...
pip show faster-whisper-cli >nul 2>&1 || pip install faster-whisper-cli
pip show ffmpeg-python    >nul 2>&1 || pip install ffmpeg-python
echo.

:: 9. Instalar onnxruntime-gpu para CTranslate2
echo [INFO] Instalando onnxruntime-gpu...
pip show onnxruntime-gpu >nul 2>&1 || pip install onnxruntime-gpu
echo.

:: 10. Verificar runtime CUDA (cuBLAS)
echo [INFO] Comprobando cublas64_12.dll...
where cublas64_12.dll >nul 2>&1
if errorlevel 1 (
    echo [INFO] CUDA runtime no encontrado. Instalando CUDA Toolkit 12...
    choco install cuda -y
    if errorlevel 1 (
        echo [ERROR] No se pudo instalar CUDA Toolkit. Instálalo manualmente desde NVIDIA.
        pause & exit /b
    )
    echo [INFO] CUDA Toolkit instalado.
) else (
    echo [INFO] CUDA runtime encontrado.
)
echo.

:: 10b. Añadir CUDA al PATH de usuario permanentemente
for /f "delims=" %%D in ('dir /b /ad "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA"') do set "CUDADIR=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\%%D"
setx PATH "%PATH%;%CUDADIR%\bin;%CUDADIR%\lib\x64" >nul
echo [INFO] Rutas CUDA añadidas al PATH de usuario. Cierra sesión o reinicia CMD para aplicar cambios.
echo.

:: 11. Pre-descargar modelo distil-large-v2
echo [INFO] Descargando distil-large-v2...
python -c "from faster_whisper import WhisperModel; WhisperModel('distil-large-v2', device='cuda')"
if errorlevel 1 (
    echo [ERROR] No se pudo descargar el modelo distil-large-v2.
    pause & exit /b
)
echo [INFO] Modelo distil-large-v2 descargado correctamente.
echo.

echo ===============================================
echo  Instalación completa. Ejecuta 02_transcriptor.bat
echo ===============================================
pause
exit /b
