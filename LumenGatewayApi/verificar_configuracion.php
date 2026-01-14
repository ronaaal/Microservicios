<?php

require_once __DIR__.'/vendor/autoload.php';

(new Laravel\Lumen\Bootstrap\LoadEnvironmentVariables(
    dirname(__DIR__)
))->bootstrap();

echo "=== VERIFICACIÓN DE CONFIGURACIÓN DEL GATEWAY ===\n\n";

$authorsUrl = config('services.authors.base_uri');
$booksUrl = config('services.books.base_uri');

echo "AUTHORS_SERVICE_BASE_URL: " . ($authorsUrl ?: 'NO CONFIGURADO') . "\n";
echo "BOOKS_SERVICE_BASE_URL: " . ($booksUrl ?: 'NO CONFIGURADO') . "\n\n";

if (empty($authorsUrl)) {
    echo "❌ ERROR: AUTHORS_SERVICE_BASE_URL no está configurado\n";
    echo "   Debe ser: http://localhost:8001\n";
} elseif ($authorsUrl === 'http://localhost:8000') {
    echo "❌ ERROR: AUTHORS_SERVICE_BASE_URL está apuntando al Gateway (8000)\n";
    echo "   Debe ser: http://localhost:8001\n";
} else {
    echo "✓ AUTHORS_SERVICE_BASE_URL está configurado correctamente\n";
}

if (empty($booksUrl)) {
    echo "❌ ERROR: BOOKS_SERVICE_BASE_URL no está configurado\n";
    echo "   Debe ser: http://localhost:8002\n";
} elseif ($booksUrl === 'http://localhost:8000') {
    echo "❌ ERROR: BOOKS_SERVICE_BASE_URL está apuntando al Gateway (8000)\n";
    echo "   Debe ser: http://localhost:8002\n";
} else {
    echo "✓ BOOKS_SERVICE_BASE_URL está configurado correctamente\n";
}

echo "\n=== INSTRUCCIONES ===\n";
echo "Edita el archivo .env y asegúrate de tener:\n";
echo "AUTHORS_SERVICE_BASE_URL=http://localhost:8001\n";
echo "BOOKS_SERVICE_BASE_URL=http://localhost:8002\n";
echo "\nLuego reinicia el Gateway.\n";
