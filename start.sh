#!/usr/bin/env bash
# Inicializa o servidor dedicado Cubyx na AWS
# Uso: ./start.sh [--world <nome>] [--create-world <nome>] [--port <porta>]
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"
exec ./dedicated_server "$@"
