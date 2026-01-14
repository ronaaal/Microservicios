#!/bin/bash

# Script de prueba simple del Gateway
GATEWAY_URL="http://localhost:8000"

echo "=== PRUEBA SIMPLE DEL GATEWAY ==="
echo ""

echo "1. Probando GET /authors..."
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "$GATEWAY_URL/authors" 2>&1)
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ -z "$http_code" ]; then
    echo "   ✗ Error: No se pudo conectar al Gateway"
    echo "   Asegúrate de que el Gateway esté corriendo en el puerto 8000"
    exit 1
fi

echo "   HTTP Code: $http_code"
echo "   Respuesta (primeros 200 caracteres):"
echo "   ${body:0:200}..."
echo ""

if [ "$http_code" -eq 200 ]; then
    echo "   ✓ GET /authors funcionó correctamente"
else
    echo "   ✗ GET /authors falló con código HTTP $http_code"
    echo "   Respuesta completa:"
    echo "$body"
fi

echo ""
echo "2. Probando GET /books..."
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "$GATEWAY_URL/books" 2>&1)
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

echo "   HTTP Code: $http_code"
if [ "$http_code" -eq 200 ]; then
    echo "   ✓ GET /books funcionó correctamente"
else
    echo "   ✗ GET /books falló con código HTTP $http_code"
fi

echo ""
echo "=== FIN DE PRUEBAS ==="
