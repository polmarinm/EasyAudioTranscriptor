#!/usr/bin/env bash
set -e  # Detener el script en caso de error

echo "==============================================="
echo " Instalador de dependencias para Whisper (macOS)"
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

# Si Homebrew se instaló en /opt/homebrew (Apple Silicon), asegurar que esté en el PATH
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# Guardar la ruta del script (para usarla más adelante)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Cambiar a HOME para que brew update funcione correctamente
cd ~
echo "[INFO] Actualizando Homebrew..."
brew update

# Volver al directorio del script para el resto de operaciones
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

# 4. Crear (si no existe) un entorno virtual
if [ ! -d "whisper_env" ]; then
  echo "[INFO] Creando entorno virtual 'whisper_env'..."
  python3 -m venv whisper_env
else
  echo "[INFO] El entorno virtual 'whisper_env' ya existe."
fi

echo

# 5. Activar el entorno virtual
echo "[INFO] Activando el entorno virtual..."
source whisper_env/bin/activate || { echo "[ERROR] No se pudo activar el entorno virtual."; exit 1; }

echo

# 6. Actualizar pip
echo "[INFO] Actualizando pip..."
pip install --upgrade pip

echo

# 7. Instalar PyTorch (CPU/MPS) según la arquitectura
ARCH=$(uname -m)
if [ "$ARCH" == "arm64" ]; then
  echo "[INFO] Apple Silicon detectado (ARM64). Instalando PyTorch con soporte MPS..."
  pip show torch &>/dev/null || pip install torch torchvision torchaudio
else
  echo "[INFO] Instalando PyTorch para CPU..."
  pip show torch &>/dev/null || pip install torch torchvision torchaudio
fi

echo

# 8. Instalar Whisper y ffmpeg-python de forma individual
echo "[INFO] Verificando instalación de Whisper y ffmpeg-python..."
pip show openai-whisper &>/dev/null || pip install openai-whisper
pip show ffmpeg-python &>/dev/null || pip install ffmpeg-python

echo

# 9. Descargar el modelo 'small' (opcional)
echo "[INFO] Descargando el modelo 'small' de Whisper..."
python3 -c "import whisper; whisper.load_model('small')" || { echo "[ERROR] Error al descargar el modelo 'small'."; exit 1; }
echo "[INFO] Modelo 'small' descargado correctamente."

echo
echo "==============================================="
echo " Instalación completa. Ya puedes usar Whisper."
echo "==============================================="