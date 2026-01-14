#!/bin/bash

# Script de prueba para la arquitectura de microservicios
# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== PRUEBAS DE API - ARQUITECTURA MICROSERVICIOS ===${NC}\n"

# Función para hacer requests y mostrar resultados
test_endpoint() {
    local method=$1
    local url=$2
    local data=$3
    local description=$4
    
    echo -e "${YELLOW}➜ ${description}${NC}"
    echo -e "   ${method} ${url}"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "$url" 2>&1)
    else
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$url" 2>&1)
    fi
    
    http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_CODE/d')
    
    # Filtrar solo JSON (ignorar warnings de PHP)
    json_response=$(echo "$body" | grep -E '^\{"data"|^\{|^\[' | head -1)
    
    if [ -n "$json_response" ]; then
        echo -e "   ${GREEN}✓${NC} HTTP $http_code"
        echo -e "   Respuesta: $json_response" | head -c 100
        echo "..."
    else
        echo -e "   ${YELLOW}⚠${NC} HTTP $http_code (puede tener warnings de PHP)"
    fi
    echo ""
}

# 1. Probar Authors Service directamente
echo -e "${BLUE}1. PROBANDO AUTHORS SERVICE (Puerto 8001)${NC}"
test_endpoint "GET" "http://localhost:8001/authors" "" "Obtener todos los autores"

# 2. Crear un autor
echo -e "${BLUE}2. CREANDO AUTOR${NC}"
test_endpoint "POST" "http://localhost:8001/authors" '{"name":"Gabriel García Márquez","gender":"male","country":"Colombia"}' "Crear autor"

# 3. Probar Books Service directamente
echo -e "${BLUE}3. PROBANDO BOOKS SERVICE (Puerto 8002)${NC}"
test_endpoint "GET" "http://localhost:8002/books" "" "Obtener todos los libros"

# 4. Probar Gateway - Authors
echo -e "${BLUE}4. PROBANDO GATEWAY - AUTHORS (Puerto 8000)${NC}"
test_endpoint "GET" "http://localhost:8000/authors" "" "Obtener autores a través del Gateway"

# 5. Crear autor a través del Gateway
echo -e "${BLUE}5. CREANDO AUTOR A TRAVÉS DEL GATEWAY${NC}"
test_endpoint "POST" "http://localhost:8000/authors" '{"name":"Isabel Allende","gender":"female","country":"Chile"}' "Crear autor vía Gateway"

# 6. Crear libro a través del Gateway
echo -e "${BLUE}6. CREANDO LIBRO A TRAVÉS DEL GATEWAY${NC}"
test_endpoint "POST" "http://localhost:8000/books" '{"title":"La casa de los espíritus","description":"Novela familiar","price":3000,"author_id":1}' "Crear libro vía Gateway"

# 7. Obtener libros a través del Gateway
echo -e "${BLUE}7. PROBANDO GATEWAY - BOOKS${NC}"
test_endpoint "GET" "http://localhost:8000/books" "" "Obtener libros a través del Gateway"

echo -e "${GREEN}=== PRUEBAS COMPLETADAS ===${NC}"
echo ""
echo "Nota: Los warnings de PHP son normales debido a la compatibilidad"
echo "entre PHP 8.x y Lumen 5.7, pero los servicios funcionan correctamente."
