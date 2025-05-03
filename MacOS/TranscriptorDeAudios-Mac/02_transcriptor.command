#!/usr/bin/env bash
set -e

# 1. Ir al directorio del script
cd "$(dirname "$0")"

# 2. Ajustar PATH para Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# 3. Activar entorno virtual
echo "==============================================="
echo " Activando entorno virtual 'whisper_env'..."
echo "==============================================="
echo
source whisper_env/bin/activate

# 4. Verificar ffmpeg y Python
command -v ffmpeg >/dev/null 2>&1 || { echo "[ERROR] ffmpeg no encontrado."; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "[ERROR] python3 no encontrado."; exit 1; }

# 5. Crear / comprobar carpetas
mkdir -p audios transcripciones

echo "==============================================="
echo " Iniciando transcripción con faster_whisper"
echo "==============================================="
echo

# 6. Procesar cada archivo
shopt -s nullglob
for INPUT in audios/*.*; do
  [ -f "$INPUT" ] || continue

  BASENAME="$(basename "$INPUT")"
  BASE="${BASENAME%.*}"
  OUT="transcripciones/${BASE}.txt"

  echo "-----------------------------------------------"
  echo "Procesando: $INPUT -> $OUT"

  # eliminamos previo
  rm -f "$OUT"

  # Ejecutamos Python inline
  python3 - << 'PYCODE'
import sys
from faster_whisper import WhisperModel

input_path = sys.argv[1]
output_path = sys.argv[2]

# Cargamos el modelo (se mantendrá en caché una vez descargado)
model = WhisperModel("distil-large-v2", device="mps")

# Transcribimos
segments, _ = model.transcribe(input_path, beam_size=5)

# Escribimos resultado
with open(output_path, "w") as f:
    for segment in segments:
        f.write(segment.text.strip() + "\n")
PYCODE
  # Pasamos rutas al bloque Python
  if [ $? -ne 0 ]; then
    echo "[ERROR] Falló la transcripción de '$INPUT'."
    continue
  fi

  echo "[INFO] Transcripción guardada en $OUT"
  echo
done
shopt -u nullglob

echo "==============================================="
echo " Proceso completado."
echo "==============================================="
