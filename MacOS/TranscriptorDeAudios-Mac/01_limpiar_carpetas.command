#!/usr/bin/env bash

set -e

echo "==============================================="
echo " Este script eliminará todos los archivos de:"
echo "   - audios/"
echo "   - transcripciones/"
echo "¡Esta acción es irreversible!"
echo "==============================================="
echo

read -p "¿Seguro que deseas continuar? (S/n) " CONFIRMAR

# Si el usuario no teclea nada, se asume "S"
if [ -z "$CONFIRMAR" ]; then
  CONFIRMAR="S"
fi

# Si el usuario pone n/N -> cancelar
if [[ "$CONFIRMAR" =~ ^[Nn]$ ]]; then
  echo
  echo "[INFO] Operación cancelada. No se ha eliminado nada."
  exit 0
fi

# Crear directorios si no existen
if [ ! -d "audios" ]; then
  echo "[INFO] El directorio 'audios/' no existe. Creándolo..."
  mkdir -p audios
fi

if [ ! -d "transcripciones" ]; then
  echo "[INFO] El directorio 'transcripciones/' no existe. Creándolo..."
  mkdir -p transcripciones
fi

# Activar dotglob para incluir archivos ocultos en el patrón *
shopt -s dotglob

# Borrar archivos en audios/ y subcarpetas
echo
echo "[INFO] Eliminando contenido de 'audios/'..."
rm -rf audios/*

# Borrar archivos en transcripciones/ y subcarpetas
echo "[INFO] Eliminando contenido de 'transcripciones/'..."
rm -rf transcripciones/*

# Desactivar dotglob para no afectar a otros procesos
shopt -u dotglob

echo
echo "[INFO] Se han eliminado todos los archivos de 'audios/' y 'transcripciones/'."
