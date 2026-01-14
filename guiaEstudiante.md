# Guía del Estudiante - Arquitectura de Microservicios

Esta guía te ayudará a entender y extender el proyecto de arquitectura de microservicios con Laravel Lumen.

## 📚 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Crear un Nuevo Microservicio](#crear-un-nuevo-microservicio)
4. [Integrar el Nuevo Servicio con el Gateway](#integrar-el-nuevo-servicio-con-el-gateway)
5. [Consumir Otros Servicios desde el Nuevo Microservicio](#consumir-otros-servicios-desde-el-nuevo-microservicio)
6. [Ejemplo Completo: Servicio de Reviews](#ejemplo-completo-servicio-de-reviews)
7. [Pruebas y Validación](#pruebas-y-validación)
8. [Mejores Prácticas](#mejores-prácticas)

---

## Introducción

Este proyecto implementa una arquitectura de microservicios donde cada servicio es independiente y se comunica mediante HTTP REST. El Gateway actúa como punto de entrada único para todos los clientes.

### Objetivos de Aprendizaje

Al finalizar esta guía, serás capaz de:

- ✅ Crear un nuevo microservicio desde cero
- ✅ Integrar un nuevo servicio con el API Gateway
- ✅ Consumir otros microservicios desde tu nuevo servicio
- ✅ Implementar validaciones entre servicios
- ✅ Probar y validar tu implementación

---

## Estructura del Proyecto

```
arquitecturaMicroServicios/
├── LumenAuthorsApi/          # Microservicio de Autores
├── LumenBooksApi/            # Microservicio de Libros
├── LumenGatewayApi/          # API Gateway
└── [TuNuevoServicio]/        # Tu nuevo microservicio
```

### Componentes Clave de un Microservicio

Cada microservicio debe tener:

1. **Modelo** (`app/Model.php`): Representa la entidad de base de datos
2. **Controlador** (`app/Http/Controllers/Controller.php`): Maneja las peticiones HTTP
3. **Rutas** (`routes/web.php`): Define los endpoints del servicio
4. **Migraciones** (`database/migrations/`): Define la estructura de la base de datos
5. **Trait ApiResponser** (`app/Traits/ApiResponser.php`): Estandariza las respuestas JSON

---

## Crear un Nuevo Microservicio

En esta sección aprenderás a crear un nuevo microservicio paso a paso. Usaremos el ejemplo de un **Servicio de Reviews** que permitirá a los usuarios dejar reseñas de libros.

### Paso 1: Crear la Estructura del Proyecto

#### 1.1 Crear el directorio del nuevo servicio

```bash
cd arquitecturaMicroServicios
mkdir LumenReviewsApi
cd LumenReviewsApi
```

#### 1.2 Instalar Lumen usando Composer

```bash
composer create-project laravel/lumen .
```

O si prefieres crear el proyecto manualmente, copia la estructura de `LumenAuthorsApi` o `LumenBooksApi` como base.

#### 1.3 Configurar composer.json

Asegúrate de que `composer.json` tenga las dependencias correctas:

```json
{
    "require": {
        "php": ">=8.1",
        "laravel/lumen-framework": "^10.0",
        "vlucas/phpdotenv": "^5.5",
        "guzzlehttp/guzzle": "^7.8"
    },
    "require-dev": {
        "fakerphp/faker": "^1.9.1",
        "phpunit/phpunit": "^10.0",
        "mockery/mockery": "^1.6"
    }
}
```

> **Nota**: Agregamos `guzzlehttp/guzzle` porque nuestro servicio consumirá otros microservicios.

### Paso 2: Configurar Variables de Entorno

Crea el archivo `.env` en `LumenReviewsApi/.env`:

```env
APP_NAME=LumenReviewsApi
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8003
APP_TIMEZONE=UTC

DB_CONNECTION=sqlite
DB_DATABASE=/ruta/completa/a/LumenReviewsApi/database/database.sqlite

# URLs de otros servicios que consumiremos
AUTHORS_SERVICE_BASE_URL=http://localhost:8001
BOOKS_SERVICE_BASE_URL=http://localhost:8002

LOG_CHANNEL=stack
LOG_SLACK_WEBHOOK_URL=
```

> **Importante**: 
> - El puerto `8003` es para el nuevo servicio
> - Las URLs de `AUTHORS_SERVICE_BASE_URL` y `BOOKS_SERVICE_BASE_URL` son necesarias para consumir esos servicios

### Paso 3: Crear la Migración

Crea el archivo `database/migrations/2024_01_01_000000_create_reviews_table.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateReviewsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->increments('id');
            $table->string('comment');
            $table->integer('rating'); // 1-5 estrellas
            $table->integer('book_id'); // ID del libro (referencia externa)
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('reviews');
    }
}
```

Ejecuta la migración:

```bash
php artisan migrate
```

### Paso 4: Crear el Modelo

Crea el archivo `app/Review.php`:

```php
<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'comment',
        'rating',
        'book_id',
    ];
}
```

### Paso 5: Crear el Trait ApiResponser

Crea el archivo `app/Traits/ApiResponser.php`:

```php
<?php

namespace App\Traits;

use Illuminate\Http\Response;

trait ApiResponser
{
    public function successResponse($data, $code = Response::HTTP_OK)
    {
        return response()->json(['data' => $data], $code);
    }

    public function errorResponse($message, $code)
    {
        return response()->json(['error' => $message, 'code' => $code], $code);
    }
}
```

### Paso 6: Crear el Trait ConsumesExternalService

Crea el archivo `app/Traits/ConsumesExternalService.php`:

```php
<?php

namespace App\Traits;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;

trait ConsumesExternalService
{
    public function performRequest($method, $requestUrl, $formParams = [], $headers = [])
    {
        // Validate baseUri is set
        if (empty($this->baseUri)) {
            throw new \RuntimeException('Base URI is not configured. Please check your .env file.');
        }

        $client = new Client([
            'base_uri' => $this->baseUri,
            'timeout' => 10.0,
        ]);

        if (isset($this->secret)) {
            $headers['Authorization'] = $this->secret;
        }

        $options = ['headers' => $headers];

        if (!empty($formParams)) {
            if (in_array(strtoupper($method), ['GET', 'DELETE'])) {
                $options['query'] = $formParams;
            } else {
                $options['json'] = $formParams;
            }
        }

        try {
            $response = $client->request($method, $requestUrl, $options);

            $body = $response->getBody()->getContents();
            $decoded = json_decode($body, true);

            if (json_last_error() === JSON_ERROR_NONE) {
                // Si la respuesta tiene 'data', extraerlo
                if (isset($decoded['data']) && is_array($decoded) && count($decoded) === 1) {
                    return $decoded['data'];
                }
                return $decoded;
            }
            return $body;
        } catch (ClientException $e) {
            throw $e;
        } catch (\Exception $e) {
            throw $e;
        }
    }
}
```

### Paso 7: Crear los Servicios para Consumir Otros Microservicios

#### 7.1 Servicio para consumir Books

Crea el archivo `app/Services/BookService.php`:

```php
<?php

namespace App\Services;

use App\Traits\ConsumesExternalService;

class BookService
{
    use ConsumesExternalService;

    /**
     * The base uri to be used to consume the books service
     * @var string
     */
    public $baseUri;

    /**
     * The secret to be used to consume the books service
     * @var string
     */
    public $secret;

    public function __construct()
    {
        $this->baseUri = env('BOOKS_SERVICE_BASE_URL');
        $this->secret = env('BOOKS_SERVICE_SECRET');
        
        // Validate configuration
        if (empty($this->baseUri)) {
            throw new \RuntimeException('BOOKS_SERVICE_BASE_URL is not configured in .env file');
        }
    }

    /**
     * Get a single book from the books service
     * @return array
     */
    public function obtainBook($book)
    {
        return $this->performRequest('GET', "/books/{$book}");
    }
}
```

#### 7.2 Servicio para consumir Authors (opcional, si necesitas validar autores)

Crea el archivo `app/Services/AuthorService.php`:

```php
<?php

namespace App\Services;

use App\Traits\ConsumesExternalService;

class AuthorService
{
    use ConsumesExternalService;

    public $baseUri;
    public $secret;

    public function __construct()
    {
        $this->baseUri = env('AUTHORS_SERVICE_BASE_URL');
        $this->secret = env('AUTHORS_SERVICE_SECRET');
        
        if (empty($this->baseUri)) {
            throw new \RuntimeException('AUTHORS_SERVICE_BASE_URL is not configured in .env file');
        }
    }

    /**
     * Get a single author from the authors service
     * @return array
     */
    public function obtainAuthor($author)
    {
        return $this->performRequest('GET', "/authors/{$author}");
    }
}
```

### Paso 8: Crear el Controlador

Crea el archivo `app/Http/Controllers/ReviewController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Traits\ApiResponser;
use App\Review;
use App\Services\BookService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class ReviewController extends Controller
{
    use ApiResponser;

    /**
     * The service to consume the book service
     * @var BookService
     */
    public $bookService;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct(BookService $bookService)
    {
        $this->bookService = $bookService;
    }

    /**
     * Return the list of reviews
     * @return Illuminate\Http\Response
     */
    public function index()
    {
        $reviews = Review::all();
        return $this->successResponse($reviews);
    }

    /**
     * Create one new review
     * @return Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        // Validar que el libro existe antes de crear la reseña
        try {
            $this->bookService->obtainBook($request->book_id);
        } catch (\Exception $e) {
            return $this->errorResponse('The book does not exist', Response::HTTP_NOT_FOUND);
        }

        // Validar datos de entrada
        $rules = [
            'comment' => 'required|max:500',
            'rating' => 'required|integer|min:1|max:5',
            'book_id' => 'required|integer|min:1',
        ];

        $this->validate($request, $rules);

        $review = Review::create($request->all());

        return $this->successResponse($review, Response::HTTP_CREATED);
    }

    /**
     * Obtains and show one review
     * @return Illuminate\Http\Response
     */
    public function show($review)
    {
        $review = Review::findOrFail($review);
        return $this->successResponse($review);
    }

    /**
     * Update an existing review
     * @return Illuminate\Http\Response
     */
    public function update(Request $request, $review)
    {
        $review = Review::findOrFail($review);

        // Si se actualiza el book_id, validar que el libro existe
        if ($request->has('book_id')) {
            try {
                $this->bookService->obtainBook($request->book_id);
            } catch (\Exception $e) {
                return $this->errorResponse('The book does not exist', Response::HTTP_NOT_FOUND);
            }
        }

        $rules = [
            'comment' => 'max:500',
            'rating' => 'integer|min:1|max:5',
            'book_id' => 'integer|min:1',
        ];

        $this->validate($request, $rules);

        $review->fill($request->all());

        if ($review->isClean()) {
            return $this->errorResponse('At least one value must change', Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $review->save();

        return $this->successResponse($review);
    }

    /**
     * Remove an existing review
     * @return Illuminate\Http\Response
     */
    public function destroy($review)
    {
        $review = Review::findOrFail($review);
        $review->delete();

        return $this->successResponse($review);
    }
}
```

### Paso 9: Configurar las Rutas

Edita el archivo `routes/web.php`:

```php
<?php

$router->get('/reviews', 'ReviewController@index');
$router->post('/reviews', 'ReviewController@store');
$router->get('/reviews/{review}', 'ReviewController@show');
$router->put('/reviews/{review}', 'ReviewController@update');
$router->patch('/reviews/{review}', 'ReviewController@update');
$router->delete('/reviews/{review}', 'ReviewController@destroy');
```

### Paso 10: Configurar el Exception Handler

Asegúrate de que `app/Exceptions/Handler.php` maneje correctamente las excepciones:

```php
<?php

namespace App\Exceptions;

use Throwable;
use App\Traits\ApiResponser;
use Illuminate\Http\Response;
use GuzzleHttp\Exception\ClientException;
use Illuminate\Validation\ValidationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Laravel\Lumen\Exceptions\Handler as ExceptionHandler;
use Symfony\Component\HttpKernel\Exception\HttpException;

class Handler extends ExceptionHandler
{
    use ApiResponser;

    public function report(Throwable $e)
    {
        parent::report($e);
    }

    public function render($request, Throwable $e)
    {
        if ($e instanceof HttpException) {
            $code = $e->getStatusCode();
            $message = Response::$statusTexts[$code] ?? 'Unknown error';
            return $this->errorResponse($message, $code);
        }

        if ($e instanceof ModelNotFoundException) {
            $model = strtolower(class_basename($e->getModel()));
            return $this->errorResponse("Does not exist any instance of {$model} with the given id", Response::HTTP_NOT_FOUND);
        }

        if ($e instanceof ValidationException) {
            $errors = $e->validator->errors()->getMessages();
            return $this->errorResponse($errors, Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        if ($e instanceof ClientException) {
            $message = $e->getResponse()->getBody()->getContents();
            $code = $e->getResponse()->getStatusCode();
            return $this->errorResponse($message, $code);
        }

        if (env('APP_DEBUG', false)) {
            return parent::render($request, $e);
        }

        return $this->errorResponse('Unexpected error. Try later', Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}
```

### Paso 11: Iniciar el Servicio

```bash
cd LumenReviewsApi
php -S localhost:8003 -t public
```

---

## Integrar el Nuevo Servicio con el Gateway

Ahora que tienes tu nuevo microservicio funcionando, necesitas integrarlo con el Gateway para que los clientes puedan acceder a él a través del punto de entrada único.

### Paso 1: Configurar el Gateway

#### 1.1 Agregar configuración en `LumenGatewayApi/config/services.php`:

```php
<?php

return [
    'authors' => [
        'base_uri' => env('AUTHORS_SERVICE_BASE_URL'),
        'secret' => env('AUTHORS_SERVICE_SECRET'),
    ],

    'books' => [
        'base_uri' => env('BOOKS_SERVICE_BASE_URL'),
        'secret' => env('BOOKS_SERVICE_SECRET'),
    ],

    'reviews' => [
        'base_uri' => env('REVIEWS_SERVICE_BASE_URL'),
        'secret' => env('REVIEWS_SERVICE_SECRET'),
    ],
];
```

#### 1.2 Agregar variables de entorno en `LumenGatewayApi/.env`:

```env
# Reviews Service Configuration
REVIEWS_SERVICE_BASE_URL=http://localhost:8003
REVIEWS_SERVICE_SECRET=
```

### Paso 2: Crear el Servicio en el Gateway

Crea el archivo `LumenGatewayApi/app/Services/ReviewService.php`:

```php
<?php

namespace App\Services;

use App\Traits\ConsumesExternalService;

class ReviewService
{
    use ConsumesExternalService;

    /**
     * The base uri to be used to consume the reviews service
     * @var string
     */
    public $baseUri;

    /**
     * The secret to be used to consume the reviews service
     * @var string
     */
    public $secret;

    public function __construct()
    {
        $this->baseUri = config('services.reviews.base_uri');
        $this->secret = config('services.reviews.secret');
        
        // Validate configuration
        if (empty($this->baseUri)) {
            throw new \RuntimeException('REVIEWS_SERVICE_BASE_URL is not configured in .env file');
        }
    }

    /**
     * Get the full list of reviews from the reviews service
     * @return string
     */
    public function obtainReviews()
    {
        return $this->performRequest('GET', '/reviews');
    }

    /**
     * Create an instance of review using the reviews service
     * @return string
     */
    public function createReview($data)
    {
        return $this->performRequest('POST', '/reviews', $data);
    }

    /**
     * Get a single review from the reviews service
     * @return string
     */
    public function obtainReview($review)
    {
        return $this->performRequest('GET', "/reviews/{$review}");
    }

    /**
     * Edit a single review from the reviews service
     * @return string
     */
    public function editReview($data, $review)
    {
        return $this->performRequest('PUT', "/reviews/{$review}", $data);
    }

    /**
     * Remove a single review from the reviews service
     * @return string
     */
    public function deleteReview($review)
    {
        return $this->performRequest('DELETE', "/reviews/{$review}");
    }
}
```

### Paso 3: Crear el Controlador en el Gateway

Crea el archivo `LumenGatewayApi/app/Http/Controllers/ReviewController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Traits\ApiResponser;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\Services\ReviewService;
use App\Services\BookService;

class ReviewController extends Controller
{
    use ApiResponser;

    /**
     * The service to consume the review service
     * @var ReviewService
     */
    public $reviewService;

    /**
     * The service to consume the book service
     * @var BookService
     */
    public $bookService;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct(ReviewService $reviewService, BookService $bookService)
    {
        $this->reviewService = $reviewService;
        $this->bookService = $bookService;
    }

    /**
     * Retrieve and show all the reviews
     * @return Illuminate\Http\Response
     */
    public function index()
    {
        return $this->successResponse($this->reviewService->obtainReviews());
    }

    /**
     * Creates an instance of review
     * @return Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        // Validar que el libro existe antes de crear la reseña
        if ($request->has('book_id')) {
            try {
                $this->bookService->obtainBook($request->book_id);
            } catch (\Exception $e) {
                return $this->errorResponse('The book does not exist', Response::HTTP_NOT_FOUND);
            }
        }

        return $this->successResponse(
            $this->reviewService->createReview($request->all()),
            Response::HTTP_CREATED
        );
    }

    /**
     * Obtain and show an instance of review
     * @return Illuminate\Http\Response
     */
    public function show($review)
    {
        return $this->successResponse($this->reviewService->obtainReview($review));
    }

    /**
     * Updated an instance of review
     * @return Illuminate\Http\Response
     */
    public function update(Request $request, $review)
    {
        // Validar que el libro existe si se está actualizando
        if ($request->has('book_id')) {
            try {
                $this->bookService->obtainBook($request->book_id);
            } catch (\Exception $e) {
                return $this->errorResponse('The book does not exist', Response::HTTP_NOT_FOUND);
            }
        }

        return $this->successResponse(
            $this->reviewService->editReview($request->all(), $review)
        );
    }

    /**
     * Removes an instance of review
     * @return Illuminate\Http\Response
     */
    public function destroy($review)
    {
        return $this->successResponse($this->reviewService->deleteReview($review));
    }
}
```

### Paso 4: Agregar Rutas en el Gateway

Edita `LumenGatewayApi/routes/web.php` y agrega las rutas de reviews:

```php
<?php

// ... rutas existentes de authors y books ...

/**
 * Reviews routes
 */
$router->get('/reviews', 'ReviewController@index');
$router->post('/reviews', 'ReviewController@store');
$router->get('/reviews/{review}', 'ReviewController@show');
$router->put('/reviews/{review}', 'ReviewController@update');
$router->patch('/reviews/{review}', 'ReviewController@update');
$router->delete('/reviews/{review}', 'ReviewController@destroy');
```

### Paso 5: Reiniciar el Gateway

Reinicia el Gateway para que cargue las nuevas configuraciones:

```bash
# Detener el Gateway (Ctrl+C)
# Luego reiniciarlo
cd LumenGatewayApi
php -S localhost:8000 -t public
```

---

## Consumir Otros Servicios desde el Nuevo Microservicio

En el ejemplo anterior, el servicio de Reviews consume el servicio de Books para validar que un libro existe antes de crear una reseña. Aquí te explicamos cómo hacerlo:

### Conceptos Clave

1. **Trait ConsumesExternalService**: Proporciona el método `performRequest()` para hacer peticiones HTTP
2. **Servicios**: Clases que encapsulan la lógica para consumir otros microservicios
3. **Validación**: Siempre valida que los recursos externos existan antes de crear relaciones

### Ejemplo: Validar que un Libro Existe

En el `ReviewController`, antes de crear una reseña:

```php
public function store(Request $request)
{
    // Validar que el libro existe
    try {
        $this->bookService->obtainBook($request->book_id);
    } catch (\Exception $e) {
        return $this->errorResponse('The book does not exist', Response::HTTP_NOT_FOUND);
    }

    // Si el libro existe, crear la reseña
    $review = Review::create($request->all());
    return $this->successResponse($review, Response::HTTP_CREATED);
}
```

### Ejemplo: Obtener Información Combinada

Si necesitas combinar información de múltiples servicios, puedes hacerlo así:

```php
public function showWithBookInfo($review)
{
    $review = Review::findOrFail($review);
    
    // Obtener información del libro
    try {
        $book = $this->bookService->obtainBook($review->book_id);
        $review->book = $book;
    } catch (\Exception $e) {
        // Manejar error si el libro no existe
    }
    
    return $this->successResponse($review);
}
```

---

## Ejemplo Completo: Servicio de Reviews

### Estructura Final del Proyecto

```
LumenReviewsApi/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       └── ReviewController.php
│   ├── Services/
│   │   ├── BookService.php
│   │   └── AuthorService.php
│   ├── Traits/
│   │   ├── ApiResponser.php
│   │   └── ConsumesExternalService.php
│   ├── Review.php
│   └── Exceptions/
│       └── Handler.php
├── database/
│   ├── migrations/
│   │   └── 2024_01_01_000000_create_reviews_table.php
│   └── database.sqlite
├── routes/
│   └── web.php
└── .env
```

### Endpoints Disponibles

Una vez integrado con el Gateway, los endpoints serán:

- `GET http://localhost:8000/reviews` - Listar todas las reseñas
- `POST http://localhost:8000/reviews` - Crear una reseña
- `GET http://localhost:8000/reviews/{id}` - Obtener una reseña específica
- `PUT http://localhost:8000/reviews/{id}` - Actualizar una reseña
- `DELETE http://localhost:8000/reviews/{id}` - Eliminar una reseña

---

## Pruebas y Validación

### 1. Probar el Microservicio Directamente

```bash
# Crear una reseña
curl -X POST http://localhost:8003/reviews \
  -H "Content-Type: application/json" \
  -d '{
    "comment": "Excelente libro, muy recomendado",
    "rating": 5,
    "book_id": 1
  }'

# Listar todas las reseñas
curl http://localhost:8003/reviews

# Obtener una reseña específica
curl http://localhost:8003/reviews/1
```

### 2. Probar a través del Gateway

```bash
# Crear una reseña a través del Gateway
curl -X POST http://localhost:8000/reviews \
  -H "Content-Type: application/json" \
  -d '{
    "comment": "Muy buena lectura",
    "rating": 4,
    "book_id": 1
  }'

# Listar reseñas a través del Gateway
curl http://localhost:8000/reviews
```

### 3. Validar Manejo de Errores

```bash
# Intentar crear una reseña con un libro inexistente
curl -X POST http://localhost:8000/reviews \
  -H "Content-Type: application/json" \
  -d '{
    "comment": "Test",
    "rating": 5,
    "book_id": 99999
  }'

# Debe retornar un error 404
```

### 4. Script de Prueba Completo

Crea un archivo `test_reviews.sh`:

```bash
#!/bin/bash

GATEWAY_URL="http://localhost:8000"

echo "=== PRUEBAS DEL SERVICIO DE REVIEWS ==="
echo ""

echo "1. Crear una reseña..."
curl -X POST $GATEWAY_URL/reviews \
  -H "Content-Type: application/json" \
  -d '{"comment":"Excelente libro","rating":5,"book_id":1}'
echo ""
echo ""

echo "2. Listar todas las reseñas..."
curl $GATEWAY_URL/reviews
echo ""
echo ""

echo "3. Intentar crear reseña con libro inexistente..."
curl -X POST $GATEWAY_URL/reviews \
  -H "Content-Type: application/json" \
  -d '{"comment":"Test","rating":5,"book_id":99999}'
echo ""
echo ""

echo "=== FIN DE PRUEBAS ==="
```

Ejecuta el script:

```bash
chmod +x test_reviews.sh
bash test_reviews.sh
```

---

## Mejores Prácticas

### 1. Validación de Datos

- ✅ Siempre valida los datos de entrada en el controlador
- ✅ Valida que los recursos externos existan antes de crear relaciones
- ✅ Usa reglas de validación claras y específicas

### 2. Manejo de Errores

- ✅ Captura excepciones al consumir otros servicios
- ✅ Retorna mensajes de error claros y útiles
- ✅ Usa códigos HTTP apropiados (404, 422, 500, etc.)

### 3. Estructura de Respuestas

- ✅ Usa el trait `ApiResponser` para respuestas consistentes
- ✅ Formato estándar: `{"data": ...}` para éxito, `{"error": ..., "code": ...}` para errores

### 4. Configuración

- ✅ Usa variables de entorno para URLs de servicios
- ✅ Valida que las configuraciones estén presentes al iniciar
- ✅ Documenta las variables de entorno necesarias

### 5. Comunicación entre Servicios

- ✅ Usa HTTP REST para comunicación síncrona
- ✅ Implementa timeouts para evitar bloqueos
- ✅ Maneja errores de red apropiadamente

### 6. Base de Datos

- ✅ Cada servicio tiene su propia base de datos
- ✅ No compartas bases de datos entre servicios
- ✅ Usa migraciones para versionar el esquema

---

## Ejercicios Prácticos

### Ejercicio 1: Servicio de Ratings

Crea un servicio de Ratings que:
- Permita calificar libros (1-5 estrellas)
- Valide que el libro existe antes de crear un rating
- Se integre con el Gateway

### Ejercicio 2: Servicio de Wishlist

Crea un servicio de Wishlist que:
- Permita a los usuarios agregar libros a su lista de deseos
- Valide que el libro existe
- Consuma información del servicio de Books para mostrar detalles

### Ejercicio 3: Servicio de Recommendations

Crea un servicio de Recommendations que:
- Genere recomendaciones basadas en ratings y reviews
- Consuma información de Reviews y Books
- Retorne libros recomendados

---

## Recursos Adicionales

- [Documentación de Laravel Lumen](https://lumen.laravel.com/docs)
- [Documentación de Guzzle HTTP](https://docs.guzzlephp.org/)
- [Arquitectura del Proyecto](arquitectura.md)
- [README Principal](README.md)

---

## Preguntas Frecuentes

### ¿Puedo crear relaciones directas entre bases de datos?

No. En arquitectura de microservicios, cada servicio tiene su propia base de datos. Las relaciones se manejan mediante validaciones HTTP entre servicios.

### ¿Cómo manejo transacciones distribuidas?

Las transacciones distribuidas son complejas en microservicios. Considera usar patrones como Saga o Event Sourcing para mantener consistencia eventual.

### ¿Puedo usar el mismo puerto para múltiples servicios?

No. Cada microservicio debe ejecutarse en un puerto diferente para evitar conflictos.

### ¿Cómo escalo un microservicio específico?

Puedes escalar cada microservicio independientemente. El Gateway puede distribuir la carga entre múltiples instancias del mismo servicio usando un load balancer.

---

**¡Felicitaciones!** 🎉

Has aprendido a crear y integrar un nuevo microservicio en la arquitectura. Continúa experimentando y mejorando tus habilidades con microservicios.
