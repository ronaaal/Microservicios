#!/bin/bash

# Script para servir la documentación de APIs en un servidor HTTP local
# Esto permite visualizar la documentación correctamente en el navegador

PORT=${1:-8080}
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📚 Servidor de Documentación de APIs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Sirviendo documentación desde: $DIR"
echo "Puerto: $PORT"
echo ""
echo "Abre en tu navegador:"
echo "  🌐 http://localhost:$PORT/index.html"
echo ""
echo "Presiona Ctrl+C para detener el servidor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Intentar usar Python 3 primero
if command -v python3 &> /dev/null; then
    cd "$DIR"
    python3 -m http.server "$PORT"
# Si no está disponible, intentar con PHP
elif command -v php &> /dev/null; then
    cd "$DIR"
    php -S localhost:"$PORT"
else
    echo "❌ Error: No se encontró Python 3 ni PHP"
    echo "Por favor, instala uno de ellos para servir la documentación"
    exit 1
fi
