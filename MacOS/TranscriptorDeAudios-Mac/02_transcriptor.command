#!/usr/bin/env bash
set -e

# ----------------------------------------------------------------
# 1. Cambiar al directorio donde está este script
# ----------------------------------------------------------------
cd "$(dirname "$0")"

# ----------------------------------------------------------------
# 2. Ajustar PATH para que Finder encuentre ffmpeg (Homebrew)
#    En Apple Silicon se instala en /opt/homebrew/bin
#    En Intel, en /usr/local/bin. Verifica con 'which ffmpeg'
# ----------------------------------------------------------------
export PATH="/opt/homebrew/bin:$PATH"

# ----------------------------------------------------------------
# 3. Activar el entorno virtual
# ----------------------------------------------------------------
echo "==============================================="
echo " Activando entorno virtual 'whisper_env'..."
echo "==============================================="
echo
source whisper_env/bin/activate

# ----------------------------------------------------------------
# 4. Comprobar que 'whisper' y 'ffmpeg' son accesibles
# ----------------------------------------------------------------
command -v ffmpeg >/dev/null 2>&1 || { echo "[ERROR] ffmpeg no se encontró en el PATH."; exit 1; }
command -v whisper >/dev/null 2>&1 || { echo "[ERROR] El comando 'whisper' no se encontró en el entorno virtual."; exit 1; }

# ----------------------------------------------------------------
# 5. Verificar carpetas
# ----------------------------------------------------------------
if [ ! -d "audios" ]; then
  echo "[ERROR] La carpeta 'audios/' no existe. Por favor, créala y coloca allí los archivos de audio."
  exit 1
fi

if [ ! -d "transcripciones" ]; then
  echo "[INFO] Creando carpeta 'transcripciones/'..."
  mkdir transcripciones
fi

echo "==============================================="
echo " Iniciando proceso de conversión y transcripción"
echo "==============================================="
echo

# ----------------------------------------------------------------
# 6. Procesar todos los archivos .*
# ----------------------------------------------------------------
shopt -s nullglob

for INPUT in audios/*.*; do
  if [ ! -f "$INPUT" ]; then
    continue
  fi

  echo "-----------------------------------------------"
  echo "Procesando archivo: $INPUT"

  BASENAME="$(basename "$INPUT")"
  BASE="${BASENAME%.*}"

  set +e  # Para capturar errores individualmente
  
  # ----------------------------------------------------------------
  # 6.1 Convertir a WAV con ffmpeg
  # ----------------------------------------------------------------
  ffmpeg -y -i "$INPUT" "temp.wav"
  ffmpeg_status=$?
  if [ $ffmpeg_status -ne 0 ]; then
    echo "[ERROR] Error al convertir '$INPUT' a WAV. Se omite este archivo."
    rm -f temp.wav
    set -e
    continue
  fi

  # ----------------------------------------------------------------
  # 6.2 Transcribir con Whisper (modelo small)
  # ----------------------------------------------------------------
  whisper temp.wav --output_dir transcripciones --model small --output_format txt
  whisper_status=$?
  set -e

  if [ $whisper_status -ne 0 ]; then
    echo "[ERROR] Error al transcribir '$INPUT'. Se omite este archivo."
    rm -f temp.wav
    continue
  fi

  # ----------------------------------------------------------------
  # 6.3 Renombrar 'temp.txt' a "$BASE.txt"
  # ----------------------------------------------------------------
  if [ -f "transcripciones/temp.txt" ]; then
    if [ -f "transcripciones/$BASE.txt" ]; then
      rm "transcripciones/$BASE.txt"
    fi
    mv "transcripciones/temp.txt" "transcripciones/$BASE.txt"
    echo "[INFO] Se guardó la transcripción: transcripciones/$BASE.txt"
  else
    echo "[WARNING] No se encontró 'transcripciones/temp.txt' para '$INPUT'."
  fi

  # ----------------------------------------------------------------
  # 6.4 Eliminar archivos temporales
  # ----------------------------------------------------------------
  rm -f temp.wav
  rm -f transcripciones/temp.*

  echo
done

shopt -u nullglob

echo "==============================================="
echo " Proceso completado."
echo "==============================================="