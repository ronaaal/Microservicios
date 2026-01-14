# Lista de Servicios para Taller de Microservicios

Este documento contiene una lista de 20 servicios adicionales que pueden ser implementados como parte de un taller práctico de arquitectura de microservicios. Cada servicio está diseñado para enseñar diferentes conceptos y patrones de microservicios.

## 📋 Índice

1. [Servicios de Usuario y Autenticación](#servicios-de-usuario-y-autenticación)
2. [Servicios de Contenido y Comentarios](#servicios-de-contenido-y-comentarios)
3. [Servicios de Comercio](#servicios-de-comercio)
4. [Servicios de Recomendación y Búsqueda](#servicios-de-recomendación-y-búsqueda)
5. [Servicios de Gestión y Administración](#servicios-de-gestión-y-administración)
6. [Servicios de Notificaciones y Comunicación](#servicios-de-notificaciones-y-comunicación)
7. [Servicios de Análisis y Reportes](#servicios-de-análisis-y-reportes)

---

## Servicios de Usuario y Autenticación

### 1. Users Service (Servicio de Usuarios)
**Puerto sugerido**: `8003`  
**Complejidad**: ⭐⭐ (Media)

**Descripción**:  
Gestiona la información de usuarios del sistema. Permite crear, actualizar y consultar perfiles de usuarios.

**Endpoints sugeridos**:
- `GET /users` - Listar todos los usuarios
- `GET /users/{id}` - Obtener un usuario específico
- `POST /users` - Crear un nuevo usuario
- `PUT /users/{id}` - Actualizar un usuario
- `DELETE /users/{id}` - Eliminar un usuario

**Campos sugeridos**:
- `id`, `name`, `email`, `password`, `role`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Reviews, Orders, Wishlist, Cart
- Consume: Ninguno (servicio base)

**Conceptos a aprender**:
- CRUD básico
- Validación de datos
- Hash de contraseñas
- Roles de usuario

---

### 2. Auth Service (Servicio de Autenticación)
**Puerto sugerido**: `8004`  
**Complejidad**: ⭐⭐⭐ (Alta)

**Descripción**:  
Maneja la autenticación y autorización de usuarios. Genera y valida tokens JWT.

**Endpoints sugeridos**:
- `POST /auth/login` - Iniciar sesión
- `POST /auth/register` - Registrar nuevo usuario
- `POST /auth/logout` - Cerrar sesión
- `POST /auth/refresh` - Refrescar token
- `GET /auth/me` - Obtener usuario autenticado

**Relaciones**:
- Consumido por: Gateway (middleware de autenticación)
- Consume: Users Service

**Conceptos a aprender**:
- JWT (JSON Web Tokens)
- Middleware de autenticación
- Encriptación y seguridad
- Refresh tokens

---

## Servicios de Contenido y Comentarios

### 3. Reviews Service (Servicio de Reseñas)
**Puerto sugerido**: `8005`  
**Complejidad**: ⭐⭐ (Media)

**Descripción**:  
Permite a los usuarios dejar reseñas y comentarios sobre libros.

**Endpoints sugeridos**:
- `GET /reviews` - Listar todas las reseñas
- `GET /reviews/{id}` - Obtener una reseña específica
- `GET /reviews/book/{book_id}` - Obtener reseñas de un libro
- `POST /reviews` - Crear una reseña
- `PUT /reviews/{id}` - Actualizar una reseña
- `DELETE /reviews/{id}` - Eliminar una reseña

**Campos sugeridos**:
- `id`, `comment`, `rating` (1-5), `book_id`, `user_id`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Recommendations Service
- Consume: Books Service, Users Service

**Conceptos a aprender**:
- Validación de relaciones entre servicios
- Agregación de datos de múltiples servicios
- Filtrado y búsqueda

---

### 4. Comments Service (Servicio de Comentarios)
**Puerto sugerido**: `8006`  
**Complejidad**: ⭐⭐ (Media)

**Descripción**:  
Permite comentar reseñas, libros o artículos. Soporta comentarios anidados (respuestas).

**Endpoints sugeridos**:
- `GET /comments` - Listar comentarios
- `GET /comments/{id}` - Obtener un comentario
- `GET /comments/review/{review_id}` - Comentarios de una reseña
- `POST /comments` - Crear comentario
- `PUT /comments/{id}` - Actualizar comentario
- `DELETE /comments/{id}` - Eliminar comentario

**Campos sugeridos**:
- `id`, `content`, `review_id`, `user_id`, `parent_id` (para respuestas), `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway
- Consume: Reviews Service, Users Service

**Conceptos a aprender**:
- Relaciones jerárquicas (comentarios anidados)
- Validación de referencias externas
- Estructuras de datos recursivas

---

### 5. Ratings Service (Servicio de Calificaciones)
**Puerto sugerido**: `8007`  
**Complejidad**: ⭐ (Baja)

**Descripción**:  
Permite calificar libros con estrellas (1-5). Diferente de Reviews, este servicio solo maneja la calificación numérica.

**Endpoints sugeridos**:
- `GET /ratings` - Listar todas las calificaciones
- `GET /ratings/book/{book_id}` - Calificaciones de un libro
- `GET /ratings/book/{book_id}/average` - Promedio de calificaciones
- `POST /ratings` - Crear calificación
- `PUT /ratings/{id}` - Actualizar calificación
- `DELETE /ratings/{id}` - Eliminar calificación

**Campos sugeridos**:
- `id`, `rating` (1-5), `book_id`, `user_id`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Recommendations Service, Analytics Service
- Consume: Books Service, Users Service

**Conceptos a aprender**:
- Cálculos agregados (promedios)
- Validación de unicidad (un usuario solo puede calificar un libro una vez)
- Operaciones matemáticas en microservicios

---

## Servicios de Comercio

### 6. Orders Service (Servicio de Pedidos)
**Puerto sugerido**: `8008`  
**Complejidad**: ⭐⭐⭐ (Alta)

**Descripción**:  
Gestiona pedidos de libros. Maneja el proceso completo desde la creación hasta la entrega.

**Endpoints sugeridos**:
- `GET /orders` - Listar todos los pedidos
- `GET /orders/{id}` - Obtener un pedido específico
- `GET /orders/user/{user_id}` - Pedidos de un usuario
- `POST /orders` - Crear un nuevo pedido
- `PUT /orders/{id}` - Actualizar estado del pedido
- `DELETE /orders/{id}` - Cancelar pedido

**Campos sugeridos**:
- `id`, `user_id`, `status` (pending, processing, shipped, delivered, cancelled), `total`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Notifications Service, Shipping Service
- Consume: Users Service, Books Service, Cart Service

**Conceptos a aprender**:
- Estados y máquinas de estado
- Validación de inventario
- Integración con múltiples servicios
- Manejo de transacciones distribuidas

---

### 7. Cart Service (Servicio de Carrito de Compras)
**Puerto sugerido**: `8009`  
**Complejidad**: ⭐⭐ (Media)

**Descripción**:  
Gestiona el carrito de compras de los usuarios. Permite agregar, eliminar y modificar items.

**Endpoints sugeridos**:
- `GET /cart/{user_id}` - Obtener carrito de un usuario
- `POST /cart/items` - Agregar item al carrito
- `PUT /cart/items/{id}` - Actualizar cantidad
- `DELETE /cart/items/{id}` - Eliminar item
- `DELETE /cart/{user_id}/clear` - Vaciar carrito
- `POST /cart/{user_id}/checkout` - Procesar compra

**Campos sugeridos**:
- `id`, `user_id`, `book_id`, `quantity`, `price`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Orders Service
- Consume: Books Service, Users Service, Inventory Service

**Conceptos a aprender**:
- Sesiones y estado temporal
- Validación de disponibilidad
- Cálculo de totales
- Integración con servicio de pedidos

---

### 8. Payments Service (Servicio de Pagos)
**Puerto sugerido**: `8010`  
**Complejidad**: ⭐⭐⭐⭐ (Muy Alta)

**Descripción**:  
Procesa pagos de pedidos. Simula integración con pasarelas de pago.

**Endpoints sugeridos**:
- `POST /payments` - Procesar pago
- `GET /payments/{id}` - Obtener estado de pago
- `GET /payments/order/{order_id}` - Pagos de un pedido
- `POST /payments/{id}/refund` - Procesar reembolso
- `GET /payments/user/{user_id}` - Historial de pagos

**Campos sugeridos**:
- `id`, `order_id`, `user_id`, `amount`, `payment_method`, `status` (pending, completed, failed, refunded), `transaction_id`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Orders Service, Notifications Service
- Consume: Orders Service, Users Service

**Conceptos a aprender**:
- Integración con servicios externos (simulados)
- Manejo de transacciones financieras
- Webhooks y callbacks
- Seguridad de pagos

---

### 9. Inventory Service (Servicio de Inventario)
**Puerto sugerido**: `8011`  
**Complejidad**: ⭐⭐ (Media)

**Descripción**:  
Gestiona el inventario y stock de libros. Controla la disponibilidad de productos.

**Endpoints sugeridos**:
- `GET /inventory` - Listar inventario
- `GET /inventory/book/{book_id}` - Stock de un libro
- `POST /inventory` - Agregar stock
- `PUT /inventory/{id}` - Actualizar stock
- `POST /inventory/reserve` - Reservar unidades
- `POST /inventory/release` - Liberar reservas

**Campos sugeridos**:
- `id`, `book_id`, `quantity`, `reserved_quantity`, `available_quantity`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Books Service, Cart Service, Orders Service
- Consume: Books Service

**Conceptos a aprender**:
- Control de concurrencia
- Reservas y bloqueos
- Validación de disponibilidad
- Optimistic locking

---

### 10. Shipping Service (Servicio de Envíos)
**Puerto sugerido**: `8012`  
**Complejidad**: ⭐⭐⭐ (Alta)

**Descripción**:  
Gestiona el envío de pedidos. Calcula costos de envío y rastrea entregas.

**Endpoints sugeridos**:
- `GET /shipping` - Listar envíos
- `GET /shipping/{id}` - Obtener un envío
- `GET /shipping/order/{order_id}` - Envío de un pedido
- `POST /shipping` - Crear envío
- `PUT /shipping/{id}` - Actualizar estado de envío
- `POST /shipping/calculate` - Calcular costo de envío

**Campos sugeridos**:
- `id`, `order_id`, `address`, `shipping_method`, `cost`, `status` (preparing, shipped, in_transit, delivered), `tracking_number`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Orders Service, Notifications Service
- Consume: Orders Service

**Conceptos a aprender**:
- Cálculo de costos dinámicos
- Integración con servicios de terceros (simulados)
- Tracking y estados de envío
- Notificaciones de cambios de estado

---

## Servicios de Recomendación y Búsqueda

### 11. Search Service (Servicio de Búsqueda)
**Puerto sugerido**: `8013`  
**Complejidad**: ⭐⭐⭐ (Alta)

**Descripción**:  
Proporciona búsqueda avanzada de libros y autores. Incluye filtros y ordenamiento.

**Endpoints sugeridos**:
- `GET /search` - Búsqueda general
- `GET /search/books` - Búsqueda de libros
- `GET /search/authors` - Búsqueda de autores
- `GET /search/suggestions` - Sugerencias de búsqueda
- `GET /search/popular` - Búsquedas populares

**Parámetros sugeridos**:
- `q` (query), `category`, `price_min`, `price_max`, `rating_min`, `sort`, `page`, `limit`

**Relaciones**:
- Consumido por: Gateway
- Consume: Books Service, Authors Service, Categories Service

**Conceptos a aprender**:
- Búsqueda full-text
- Filtrado avanzado
- Paginación
- Caché de resultados

---

### 12. Recommendations Service (Servicio de Recomendaciones)
**Puerto sugerido**: `8014`  
**Complejidad**: ⭐⭐⭐⭐ (Muy Alta)

**Descripción**:  
Genera recomendaciones personalizadas de libros basadas en historial, ratings y preferencias.

**Endpoints sugeridos**:
- `GET /recommendations/user/{user_id}` - Recomendaciones para un usuario
- `GET /recommendations/book/{book_id}/similar` - Libros similares
- `GET /recommendations/popular` - Libros populares
- `POST /recommendations/train` - Entrenar modelo (admin)

**Relaciones**:
- Consumido por: Gateway
- Consume: Books Service, Ratings Service, Reviews Service, Users Service, Orders Service

**Conceptos a aprender**:
- Algoritmos de recomendación
- Agregación de datos de múltiples servicios
- Machine Learning básico
- Caché de recomendaciones

---

### 13. Categories Service (Servicio de Categorías)
**Puerto sugerido**: `8015`  
**Complejidad**: ⭐ (Baja)

**Descripción**:  
Gestiona categorías y géneros de libros (Ficción, No Ficción, Ciencia, Historia, etc.).

**Endpoints sugeridos**:
- `GET /categories` - Listar todas las categorías
- `GET /categories/{id}` - Obtener una categoría
- `GET /categories/{id}/books` - Libros de una categoría
- `POST /categories` - Crear categoría
- `PUT /categories/{id}` - Actualizar categoría
- `DELETE /categories/{id}` - Eliminar categoría

**Campos sugeridos**:
- `id`, `name`, `description`, `parent_id` (para subcategorías), `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Books Service, Search Service
- Consume: Ninguno

**Conceptos a aprender**:
- Estructuras jerárquicas
- Relaciones muchos a muchos (libros-categorías)
- Validación de referencias

---

## Servicios de Gestión y Administración

### 14. Publishers Service (Servicio de Editoriales)
**Puerto sugerido**: `8016`  
**Complejidad**: ⭐ (Baja)

**Descripción**:  
Gestiona información de editoriales que publican libros.

**Endpoints sugeridos**:
- `GET /publishers` - Listar editoriales
- `GET /publishers/{id}` - Obtener una editorial
- `GET /publishers/{id}/books` - Libros de una editorial
- `POST /publishers` - Crear editorial
- `PUT /publishers/{id}` - Actualizar editorial
- `DELETE /publishers/{id}` - Eliminar editorial

**Campos sugeridos**:
- `id`, `name`, `country`, `website`, `founded_year`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Books Service
- Consume: Ninguno

**Conceptos a aprender**:
- CRUD básico
- Relaciones uno a muchos (editorial-libros)
- Validación de datos

---

### 15. Libraries Service (Servicio de Bibliotecas)
**Puerto sugerido**: `8017`  
**Complejidad**: ⭐⭐ (Media)

**Descripción**:  
Gestiona bibliotecas físicas y sus colecciones de libros. Permite préstamos y devoluciones.

**Endpoints sugeridos**:
- `GET /libraries` - Listar bibliotecas
- `GET /libraries/{id}` - Obtener una biblioteca
- `GET /libraries/{id}/books` - Libros disponibles
- `POST /libraries` - Crear biblioteca
- `PUT /libraries/{id}` - Actualizar biblioteca
- `DELETE /libraries/{id}` - Eliminar biblioteca

**Campos sugeridos**:
- `id`, `name`, `address`, `phone`, `email`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Loans Service
- Consume: Books Service

**Conceptos a aprender**:
- Gestión de ubicaciones físicas
- Relaciones con otros servicios
- Validación de disponibilidad

---

### 16. Loans Service (Servicio de Préstamos)
**Puerto sugerido**: `8018`  
**Complejidad**: ⭐⭐⭐ (Alta)

**Descripción**:  
Gestiona préstamos de libros en bibliotecas. Controla fechas de préstamo y devolución.

**Endpoints sugeridos**:
- `GET /loans` - Listar préstamos
- `GET /loans/{id}` - Obtener un préstamo
- `GET /loans/user/{user_id}` - Préstamos de un usuario
- `POST /loans` - Crear préstamo
- `PUT /loans/{id}/return` - Registrar devolución
- `GET /loans/overdue` - Préstamos vencidos

**Campos sugeridos**:
- `id`, `user_id`, `book_id`, `library_id`, `loan_date`, `due_date`, `return_date`, `status` (active, returned, overdue), `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Notifications Service
- Consume: Users Service, Books Service, Libraries Service

**Conceptos a aprender**:
- Manejo de fechas y vencimientos
- Validación de disponibilidad
- Cálculo de multas
- Estados complejos

---

### 17. Wishlist Service (Servicio de Lista de Deseos)
**Puerto sugerido**: `8019`  
**Complejidad**: ⭐⭐ (Media)

**Descripción**:  
Permite a los usuarios crear listas de deseos con libros que quieren comprar o leer.

**Endpoints sugeridos**:
- `GET /wishlist/user/{user_id}` - Lista de deseos de un usuario
- `POST /wishlist/items` - Agregar libro a lista de deseos
- `DELETE /wishlist/items/{id}` - Eliminar de lista de deseos
- `GET /wishlist/user/{user_id}/shared` - Listas compartidas

**Campos sugeridos**:
- `id`, `user_id`, `book_id`, `priority`, `notes`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway, Notifications Service, Recommendations Service
- Consume: Books Service, Users Service

**Conceptos a aprender**:
- Gestión de listas personales
- Validación de duplicados
- Compartir recursos entre usuarios

---

## Servicios de Notificaciones y Comunicación

### 18. Notifications Service (Servicio de Notificaciones)
**Puerto sugerido**: `8020`  
**Complejidad**: ⭐⭐⭐ (Alta)

**Descripción**:  
Envía notificaciones a usuarios sobre eventos importantes (pedidos, préstamos, nuevos libros, etc.).

**Endpoints sugeridos**:
- `GET /notifications/user/{user_id}` - Notificaciones de un usuario
- `POST /notifications` - Crear notificación
- `PUT /notifications/{id}/read` - Marcar como leída
- `DELETE /notifications/{id}` - Eliminar notificación
- `GET /notifications/user/{user_id}/unread` - Notificaciones no leídas

**Campos sugeridos**:
- `id`, `user_id`, `type` (order, loan, review, etc.), `title`, `message`, `read`, `created_at`, `updated_at`

**Relaciones**:
- Consumido por: Gateway
- Consume: Users Service, Orders Service, Loans Service, Reviews Service

**Conceptos a aprender**:
- Event-driven architecture
- Colas de mensajes (simuladas)
- Notificaciones en tiempo real
- Integración con múltiples servicios

---

### 19. Email Service (Servicio de Correo Electrónico)
**Puerto sugerido**: `8021`  
**Complejidad**: ⭐⭐⭐ (Alta)

**Descripción**:  
Envía correos electrónicos transaccionales (confirmaciones, recordatorios, newsletters).

**Endpoints sugeridos**:
- `POST /email/send` - Enviar correo
- `POST /email/send-bulk` - Envío masivo
- `GET /email/templates` - Listar plantillas
- `GET /email/history` - Historial de envíos

**Relaciones**:
- Consumido por: Gateway, Orders Service, Notifications Service, Auth Service
- Consume: Users Service

**Conceptos a aprender**:
- Integración con servicios de email (simulados)
- Plantillas de correo
- Envío asíncrono
- Manejo de errores de envío

---

## Servicios de Análisis y Reportes

### 20. Analytics Service (Servicio de Análisis)
**Puerto sugerido**: `8022`  
**Complejidad**: ⭐⭐⭐⭐ (Muy Alta)

**Descripción**:  
Recopila y analiza datos de uso del sistema. Genera reportes y estadísticas.

**Endpoints sugeridos**:
- `GET /analytics/books/popular` - Libros más populares
- `GET /analytics/sales/report` - Reporte de ventas
- `GET /analytics/users/activity` - Actividad de usuarios
- `GET /analytics/reviews/sentiment` - Análisis de sentimiento
- `POST /analytics/events` - Registrar evento

**Relaciones**:
- Consumido por: Gateway (admin)
- Consume: Todos los servicios (lectura de datos)

**Conceptos a aprender**:
- Agregación de datos de múltiples servicios
- Cálculos estadísticos
- Reportes complejos
- Análisis de datos
- Event sourcing básico

---

## 📊 Resumen por Complejidad

### ⭐ Baja Complejidad (Ideal para empezar)
- Ratings Service
- Categories Service
- Publishers Service

### ⭐⭐ Media Complejidad
- Users Service
- Reviews Service
- Comments Service
- Cart Service
- Inventory Service
- Libraries Service
- Wishlist Service

### ⭐⭐⭐ Alta Complejidad
- Auth Service
- Orders Service
- Payments Service
- Shipping Service
- Search Service
- Loans Service
- Notifications Service
- Email Service

### ⭐⭐⭐⭐ Muy Alta Complejidad (Proyectos avanzados)
- Recommendations Service
- Analytics Service

---

## 🎯 Recomendaciones para el Taller

### Fase 1: Fundamentos (Semana 1-2)
1. **Users Service** - Aprender CRUD básico
2. **Categories Service** - Entender relaciones simples
3. **Ratings Service** - Validar relaciones entre servicios

### Fase 2: Integración (Semana 3-4)
4. **Reviews Service** - Consumir múltiples servicios
5. **Cart Service** - Integración compleja
6. **Inventory Service** - Validación de disponibilidad

### Fase 3: Comercio (Semana 5-6)
7. **Orders Service** - Estados y flujos complejos
8. **Payments Service** - Integración con servicios externos
9. **Shipping Service** - Tracking y estados

### Fase 4: Avanzado (Semana 7-8)
10. **Search Service** - Búsqueda y filtrado
11. **Recommendations Service** - Algoritmos y agregación
12. **Analytics Service** - Análisis de datos

---

## 🔗 Servicios Relacionados

### Servicios que consumen Books Service:
- Reviews, Comments, Ratings, Cart, Inventory, Orders, Wishlist, Search, Recommendations, Analytics

### Servicios que consumen Authors Service:
- Search, Recommendations, Analytics

### Servicios que consumen Users Service:
- Auth, Reviews, Comments, Ratings, Orders, Cart, Loans, Wishlist, Notifications, Email, Analytics

---

## 📝 Notas para Instructores

1. **Orden sugerido**: Comenzar con servicios de baja complejidad y avanzar gradualmente
2. **Grupos de trabajo**: Asignar servicios relacionados para que los estudiantes colaboren
3. **Integración**: Enfatizar la importancia de integrar servicios con el Gateway
4. **Testing**: Requerir tests unitarios y de integración para cada servicio
5. **Documentación**: Incluir documentación OpenAPI para cada servicio creado

---

## 🚀 Próximos Pasos

1. Seleccionar servicios según el nivel del taller
2. Crear estructura base para cada servicio
3. Implementar endpoints básicos
4. Integrar con Gateway
5. Agregar validaciones y relaciones
6. Implementar tests
7. Documentar con OpenAPI

---

**Última actualización**: 2024  
**Versión**: 1.0
