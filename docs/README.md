# Documentación de APIs

Esta carpeta contiene la documentación completa de todas las APIs del proyecto de arquitectura de microservicios.

## 📋 Archivos Incluidos

### Archivos OpenAPI/Swagger (YAML)
- `api-authors-openapi.yaml` - Especificación OpenAPI para el servicio de Authors
- `api-books-openapi.yaml` - Especificación OpenAPI para el servicio de Books
- `api-gateway-openapi.yaml` - Especificación OpenAPI para el API Gateway

### Archivos HTML (Visualización)
- `index.html` - Página principal con índice de todas las APIs
- `api-authors.html` - Documentación interactiva del servicio de Authors
- `api-books.html` - Documentación interactiva del servicio de Books
- `api-gateway.html` - Documentación interactiva del API Gateway

## 🚀 Cómo Visualizar la Documentación

### Opción 1: Usar el script incluido (Recomendado)

```bash
# Desde la raíz del proyecto
bash docs/servir-docs.sh

# O especificar un puerto diferente
bash docs/servir-docs.sh 3000
```

Luego abre en tu navegador: `http://localhost:8080/index.html`

### Opción 2: Abrir directamente en el navegador

1. Abre el archivo `docs/index.html` en tu navegador
2. Haz clic en cualquiera de las tarjetas para ver la documentación de cada API
3. Usa el botón "Try it out" para probar los endpoints directamente

> **Nota**: Si los archivos YAML no se cargan, usa la Opción 1 o 3 para servir la documentación con un servidor HTTP.

### Opción 3: Servidor HTTP manual

Si los archivos YAML no se cargan correctamente al abrir directamente, puedes usar un servidor HTTP simple:

```bash
# Desde la carpeta docs
cd docs

# Python 3
python3 -m http.server 8080

# O con PHP
php -S localhost:8080
```

Luego abre en tu navegador: `http://localhost:8080/index.html`

### Opción 4: Servidor desde la raíz del proyecto

```bash
# Desde la raíz del proyecto
python3 -m http.server 8080 -d docs

# O con PHP
php -S localhost:8080 -t docs
```

## 📖 Características de la Documentación

- ✅ **Interactiva**: Puedes probar todos los endpoints directamente desde el navegador
- ✅ **Completa**: Incluye todos los endpoints, parámetros, respuestas y ejemplos
- ✅ **Estándar OpenAPI 3.0**: Compatible con herramientas como Postman, Insomnia, etc.
- ✅ **Visualización con Swagger UI**: Interfaz moderna y fácil de usar

## 🔧 Uso de la Documentación

### Probar Endpoints

1. Abre la documentación de la API que deseas probar
2. Expande el endpoint que quieres probar
3. Haz clic en "Try it out"
4. Completa los parámetros necesarios
5. Haz clic en "Execute"
6. Revisa la respuesta en la sección "Responses"

### Importar en Postman

1. Abre Postman
2. Haz clic en "Import"
3. Selecciona "File" y elige el archivo YAML correspondiente
4. Postman importará automáticamente todos los endpoints

### Importar en Insomnia

1. Abre Insomnia
2. Ve a "Application" > "Preferences" > "Data"
3. Haz clic en "Import Data" > "From File"
4. Selecciona el archivo YAML correspondiente

## 📝 Estructura de las APIs

### Authors API
- **Puerto**: 8001
- **Endpoints**: CRUD completo para autores
- **Modelo**: name, gender, country

### Books API
- **Puerto**: 8002
- **Endpoints**: CRUD completo para libros
- **Modelo**: title, description, price, author_id

### API Gateway
- **Puerto**: 8000
- **Endpoints**: Proxifica todas las operaciones de Authors y Books
- **Validaciones**: Valida relaciones entre servicios automáticamente

## 🔄 Actualizar la Documentación

Si necesitas actualizar la documentación después de modificar las APIs:

1. Edita el archivo YAML correspondiente
2. Los cambios se reflejarán automáticamente al recargar la página HTML
3. Asegúrate de mantener la especificación OpenAPI 3.0 válida

## 📚 Recursos Adicionales

- [Especificación OpenAPI 3.0](https://swagger.io/specification/)
- [Swagger UI](https://swagger.io/tools/swagger-ui/)
- [Documentación del Proyecto](../README.md)
- [Guía del Estudiante](../guiaEstudiante.md)
