#!/usr/bin/env bash
set -e  # Detener el script en caso de error

echo "==============================================="
echo " Instalador de dependencias para Insanely-Fast-Whisper (macOS)"
echo "==============================================="
echo

# 1. Verificar e instalar Homebrew
echo "[INFO] Verificando Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "[INFO] Homebrew no está instalado. Instalándolo..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "[INFO] Homebrew ya está instalado."
fi

# Ajustar PATH para Homebrew (Apple Silicon)
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# Guardar la ruta del script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Cambiar a HOME para brew update
cd ~
echo "[INFO] Actualizando Homebrew..."
brew update

# Volver al directorio del script
cd "$SCRIPT_DIR"
echo

# 2. Instalar ffmpeg
echo "[INFO] Verificando ffmpeg..."
if ! command -v ffmpeg &>/dev/null; then
  echo "[INFO] Instalando ffmpeg con Homebrew..."
  brew install ffmpeg
else
  echo "[INFO] ffmpeg ya está instalado."
fi
echo

# 3. Verificar Python 3
echo "[INFO] Verificando Python 3..."
if ! command -v python3 &>/dev/null; then
  echo "[INFO] Python 3 no está instalado. Instalando..."
  brew install python
else
  echo "[INFO] Python 3 ya está instalado."
fi
echo

# 4. Crear entorno virtual si no existe
if [ ! -d "whisper_env" ]; then
  echo "[INFO] Creando entorno virtual 'whisper_env'..."
  python3 -m venv whisper_env
else
  echo "[INFO] El entorno virtual 'whisper_env' ya existe."
fi
echo

# 5. Activar entorno virtual
echo "[INFO] Activando el entorno virtual..."
source whisper_env/bin/activate || { echo "[ERROR] No se pudo activar el entorno virtual."; exit 1; }
echo

# 6. Actualizar pip
echo "[INFO] Actualizando pip..."
pip install --upgrade pip
echo

# 7. Instalar PyTorch (CPU/MPS) según arquitectura
ARCH=$(uname -m)
if [ "$ARCH" == "arm64" ]; then
  echo "[INFO] Apple Silicon detectado. Instalando PyTorch con soporte MPS..."
  pip show torch &>/dev/null || pip install torch torchvision torchaudio
else
  echo "[INFO] Instalando PyTorch para CPU..."
  pip show torch &>/dev/null || pip install torch torchvision torchaudio
fi
echo

# 8. Instalar faster-whisper y onnxruntime
echo "[INFO] Verificando faster-whisper y onnxruntime..."
pip show faster-whisper &>/dev/null  || pip install faster-whisper
pip show onnxruntime    &>/dev/null  || pip install onnxruntime
echo

# 9. Descargar modelo distil-large-v2
echo "[INFO] Descargando modelo 'distil-large-v2' de faster-whisper..."
python3 - << 'PYCODE'
from faster_whisper import WhisperModel
WhisperModel("distil-large-v2", device="mps")
PYCODE
echo "[INFO] Modelo 'distil-large-v2' descargado correctamente."
echo

echo "==============================================="
echo " Instalación completa. Ya puedes usar Insanely-Fast-Whisper."
echo "==============================================="
