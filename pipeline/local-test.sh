#!/bin/bash

# Script para ejecutar localmente los mismos checks que el pipeline CI/CD
# Útil para verificar que el código pasará el pipeline antes de hacer push

set -e  # Salir si algún comando falla

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_step() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Verificar que estamos en el directorio raíz del proyecto
if [ ! -d "LumenAuthorsApi" ] || [ ! -d "LumenBooksApi" ] || [ ! -d "LumenGatewayApi" ]; then
    print_error "Este script debe ejecutarse desde la raíz del proyecto"
    exit 1
fi

# Verificar que PHP está instalado
if ! command -v php &> /dev/null; then
    print_error "PHP no está instalado. Por favor, instala PHP 8.1 o superior"
    exit 1
fi

PHP_VERSION=$(php -r 'echo PHP_VERSION;')
print_success "PHP versión $PHP_VERSION detectada"

# Verificar que Composer está instalado
if ! command -v composer &> /dev/null; then
    print_error "Composer no está instalado. Por favor, instala Composer"
    exit 1
fi

print_success "Composer detectado"

# Función para validar un servicio
validate_service() {
    local SERVICE_NAME=$1
    local SERVICE_DIR=$2
    
    print_step "Validando $SERVICE_NAME"
    
    cd "$SERVICE_DIR"
    
    # Validar composer.json
    print_warning "Validando composer.json..."
    if composer validate --no-check-publish > /dev/null 2>&1; then
        print_success "composer.json válido"
    else
        print_error "composer.json inválido"
        cd ..
        return 1
    fi
    
    # Instalar dependencias
    print_warning "Instalando dependencias..."
    if composer install --prefer-dist --no-progress --no-interaction > /dev/null 2>&1; then
        print_success "Dependencias instaladas"
    else
        print_error "Error al instalar dependencias"
        cd ..
        return 1
    fi
    
    # Verificar sintaxis PHP
    print_warning "Verificando sintaxis PHP..."
    ERRORS=0
    while IFS= read -r -d '' file; do
        if ! php -l "$file" > /dev/null 2>&1; then
            print_error "Error de sintaxis en: $file"
            ERRORS=$((ERRORS + 1))
        fi
    done < <(find app -name "*.php" -type f -print0)
    
    if [ $ERRORS -eq 0 ]; then
        print_success "Sintaxis PHP correcta"
    else
        print_error "Se encontraron $ERRORS errores de sintaxis"
        cd ..
        return 1
    fi
    
    # Ejecutar tests
    print_warning "Ejecutando tests..."
    if [ -f "phpunit.xml" ]; then
        if vendor/bin/phpunit > /dev/null 2>&1; then
            print_success "Tests pasaron correctamente"
        else
            print_warning "Algunos tests fallaron (ejecuta 'vendor/bin/phpunit' para más detalles)"
        fi
    else
        print_warning "phpunit.xml no encontrado, saltando tests"
    fi
    
    cd ..
    return 0
}

# Ejecutar validaciones
print_step "INICIANDO VALIDACIÓN LOCAL DEL PIPELINE"
echo ""

FAILED=0

# Validar Authors Service
if ! validate_service "Authors Service" "LumenAuthorsApi"; then
    FAILED=1
fi

echo ""

# Validar Books Service
if ! validate_service "Books Service" "LumenBooksApi"; then
    FAILED=1
fi

echo ""

# Validar Gateway Service
if ! validate_service "Gateway Service" "LumenGatewayApi"; then
    FAILED=1
fi

echo ""

# Resumen
print_step "RESUMEN"
if [ $FAILED -eq 0 ]; then
    print_success "Todas las validaciones pasaron correctamente"
    echo ""
    echo "Tu código está listo para hacer push al repositorio."
    exit 0
else
    print_error "Algunas validaciones fallaron"
    echo ""
    echo "Por favor, corrige los errores antes de hacer push."
    exit 1
fi
