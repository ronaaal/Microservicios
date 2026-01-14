# Arquitectura del Sistema de Microservicios

Este documento describe en detalle la arquitectura del sistema de microservicios desarrollado con Laravel Lumen.

## 📐 Diagrama de Arquitectura General

```mermaid
graph TB
    Client[Cliente API<br/>Frontend/Mobile/Postman]
    Gateway[API Gateway<br/>LumenGatewayApi<br/>Puerto: 8000]
    
    AuthorsService[Authors Service<br/>LumenAuthorsApi<br/>Puerto: 8001]
    BooksService[Books Service<br/>LumenBooksApi<br/>Puerto: 8002]
    
    AuthorsDB[(Authors Database<br/>SQLite)]
    BooksDB[(Books Database<br/>SQLite)]
    
    Client -->|HTTP Requests| Gateway
    Gateway -->|HTTP/REST<br/>Guzzle Client| AuthorsService
    Gateway -->|HTTP/REST<br/>Guzzle Client| BooksService
    
    AuthorsService -->|Eloquent ORM| AuthorsDB
    BooksService -->|Eloquent ORM| BooksDB
    
    style Gateway fill:#4CAF50,stroke:#2E7D32,color:#fff
    style AuthorsService fill:#2196F3,stroke:#1565C0,color:#fff
    style BooksService fill:#FF9800,stroke:#E65100,color:#fff
    style AuthorsDB fill:#9E9E9E,stroke:#424242,color:#fff
    style BooksDB fill:#9E9E9E,stroke:#424242,color:#fff
```

## 🔄 Flujo de Peticiones

```mermaid
sequenceDiagram
    participant C as Cliente
    participant G as API Gateway
    participant AS as Authors Service
    participant BS as Books Service
    participant ADB as Authors DB
    participant BDB as Books DB
    
    Note over C,BDB: Escenario: Crear un libro
    
    C->>G: POST /books<br/>{title, description, price, author_id}
    G->>AS: GET /authors/{author_id}<br/>(Validar que existe)
    AS->>ADB: SELECT * FROM authors WHERE id = ?
    ADB-->>AS: Author data
    AS-->>G: 200 OK {data: {...}}
    
    alt Autor existe
        G->>BS: POST /books<br/>{title, description, price, author_id}
        BS->>BDB: INSERT INTO books ...
        BDB-->>BS: Book created
        BS-->>G: 201 Created {data: {...}}
        G-->>C: 201 Created {data: {...}}
    else Autor no existe
        AS-->>G: 404 Not Found
        G-->>C: 404 Error {error: "...", code: 404}
    end
```

## 🏗️ Diagrama de Componentes

```mermaid
graph LR
    subgraph Gateway[LumenGatewayApi]
        GC[Controllers<br/>AuthorController<br/>BookController]
        GS[Services<br/>AuthorService<br/>BookService]
        GT[Traits<br/>ApiResponser<br/>ConsumesExternalService]
        GR[Routes<br/>web.php]
        GConfig[Config<br/>services.php]
    end
    
    subgraph AuthorsService[LumenAuthorsApi]
        AC[AuthorController]
        AM[Author Model]
        ART[ApiResponser Trait]
        AR[Routes<br/>web.php]
    end
    
    subgraph BooksService[LumenBooksApi]
        BC[BookController]
        BM[Book Model]
        BRT[ApiResponser Trait]
        BR[Routes<br/>web.php]
    end
    
    GC --> GS
    GS --> GT
    GT --> AuthorsService
    GT --> BooksService
    
    AC --> AM
    AC --> ART
    
    BC --> BM
    BC --> BRT
    
    style Gateway fill:#4CAF50,stroke:#2E7D32,color:#fff
    style AuthorsService fill:#2196F3,stroke:#1565C0,color:#fff
    style BooksService fill:#FF9800,stroke:#E65100,color:#fff
```

## 📊 Modelo de Datos

```mermaid
erDiagram
    AUTHORS {
        int id PK
        string name
        string gender
        string country
        timestamp created_at
        timestamp updated_at
    }
    
    BOOKS {
        int id PK
        string title
        string description
        int price
        int author_id FK
        timestamp created_at
        timestamp updated_at
    }
    
    AUTHORS ||--o{ BOOKS : "has many"
    BOOKS }o--|| AUTHORS : "belongs to"
```

## 🔀 Flujo de Operaciones CRUD

### Operación GET (Leer)

```mermaid
sequenceDiagram
    participant C as Cliente
    participant G as Gateway
    participant S as Microservicio
    participant DB as Base de Datos
    
    C->>G: GET /authors o GET /books
    G->>S: GET /authors o GET /books
    S->>DB: SELECT * FROM table
    DB-->>S: Resultados
    S->>S: Formatear respuesta<br/>{data: [...]}
    S-->>G: 200 OK {data: [...]}
    G-->>C: 200 OK {data: [...]}
```

### Operación POST (Crear)

```mermaid
sequenceDiagram
    participant C as Cliente
    participant G as Gateway
    participant S as Microservicio
    participant VS as Servicio de Validación
    participant DB as Base de Datos
    
    C->>G: POST /books<br/>{title, author_id, ...}
    
    alt Es un libro
        G->>VS: GET /authors/{author_id}<br/>(Validar autor existe)
        VS-->>G: 200 OK o 404 Not Found
        
        alt Autor existe
            G->>S: POST /books<br/>{...}
            S->>DB: INSERT INTO books
            DB-->>S: ID del nuevo libro
            S-->>G: 201 Created {data: {...}}
            G-->>C: 201 Created {data: {...}}
        else Autor no existe
            G-->>C: 404 Error {error: "...", code: 404}
        end
    else Es un autor
        G->>S: POST /authors<br/>{...}
        S->>DB: INSERT INTO authors
        DB-->>S: ID del nuevo autor
        S-->>G: 201 Created {data: {...}}
        G-->>C: 201 Created {data: {...}}
    end
```

### Operación PUT/PATCH (Actualizar)

```mermaid
sequenceDiagram
    participant C as Cliente
    participant G as Gateway
    participant S as Microservicio
    participant VS as Servicio de Validación
    participant DB as Base de Datos
    
    C->>G: PUT /books/{id}<br/>{title, author_id, ...}
    
    alt Incluye author_id
        G->>VS: GET /authors/{author_id}<br/>(Validar autor existe)
        VS-->>G: 200 OK o 404 Not Found
        
        alt Autor existe
            G->>S: PUT /books/{id}<br/>{...}
            S->>DB: UPDATE books SET ...
            DB-->>S: Registro actualizado
            S-->>G: 200 OK {data: {...}}
            G-->>C: 200 OK {data: {...}}
        else Autor no existe
            G-->>C: 404 Error {error: "...", code: 404}
        end
    else No incluye author_id
        G->>S: PUT /books/{id}<br/>{...}
        S->>DB: UPDATE books SET ...
        DB-->>S: Registro actualizado
        S-->>G: 200 OK {data: {...}}
        G-->>C: 200 OK {data: {...}}
    end
```

### Operación DELETE (Eliminar)

```mermaid
sequenceDiagram
    participant C as Cliente
    participant G as Gateway
    participant S as Microservicio
    participant DB as Base de Datos
    
    C->>G: DELETE /authors/{id} o DELETE /books/{id}
    G->>S: DELETE /authors/{id} o DELETE /books/{id}
    S->>DB: DELETE FROM table WHERE id = ?
    
    alt Registro existe
        DB-->>S: Registro eliminado
        S-->>G: 200 OK {data: {...}}
        G-->>C: 200 OK {data: {...}}
    else Registro no existe
        DB-->>S: No encontrado
        S-->>G: 404 Not Found {error: "...", code: 404}
        G-->>C: 404 Not Found {error: "...", code: 404}
    end
```

## 🌐 Arquitectura de Red

```mermaid
graph TB
    subgraph "Cliente"
        Browser[Navegador/Postman]
        Mobile[Aplicación Mobile]
        Other[Otros Clientes]
    end
    
    subgraph "Gateway Layer"
        Gateway[API Gateway<br/>localhost:8000]
    end
    
    subgraph "Microservices Layer"
        Authors[Authors Service<br/>localhost:8001]
        Books[Books Service<br/>localhost:8002]
    end
    
    subgraph "Data Layer"
        AuthorsDB[(Authors DB<br/>SQLite)]
        BooksDB[(Books DB<br/>SQLite)]
    end
    
    Browser --> Gateway
    Mobile --> Gateway
    Other --> Gateway
    
    Gateway -->|HTTP REST| Authors
    Gateway -->|HTTP REST| Books
    
    Authors --> AuthorsDB
    Books --> BooksDB
    
    style Gateway fill:#4CAF50,stroke:#2E7D32,color:#fff
    style Authors fill:#2196F3,stroke:#1565C0,color:#fff
    style Books fill:#FF9800,stroke:#E65100,color:#fff
```

## 🔧 Patrones Arquitectónicos Implementados

### 1. API Gateway Pattern

```mermaid
graph LR
    Client[Cliente]
    Gateway[API Gateway<br/>Punto de entrada único]
    
    MS1[Microservicio 1]
    MS2[Microservicio 2]
    MS3[Microservicio N]
    
    Client --> Gateway
    Gateway --> MS1
    Gateway --> MS2
    Gateway --> MS3
    
    style Gateway fill:#4CAF50,stroke:#2E7D32,color:#fff
```

**Beneficios:**
- Punto de entrada único para todos los clientes
- Enrutamiento centralizado
- Validación de reglas de negocio entre servicios
- Transformación de respuestas

### 2. Database per Service Pattern

```mermaid
graph TB
    Gateway[API Gateway]
    
    AuthorsService[Authors Service]
    BooksService[Books Service]
    
    AuthorsDB[(Authors DB)]
    BooksDB[(Books DB)]
    
    Gateway --> AuthorsService
    Gateway --> BooksService
    
    AuthorsService --> AuthorsDB
    BooksService --> BooksDB
    
    AuthorsDB -.->|Sin relación directa| BooksDB
    
    style AuthorsDB fill:#9E9E9E,stroke:#424242,color:#fff
    style BooksDB fill:#9E9E9E,stroke:#424242,color:#fff
```

**Características:**
- Cada microservicio tiene su propia base de datos
- No hay acoplamiento a nivel de datos
- Independencia de despliegue y escalado

### 3. Service Communication Pattern

```mermaid
graph LR
    Gateway[Gateway]
    
    subgraph "Comunicación Síncrona HTTP"
        Authors[Authors Service]
        Books[Books Service]
    end
    
    Gateway -->|HTTP Request<br/>Guzzle Client| Authors
    Gateway -->|HTTP Request<br/>Guzzle Client| Books
    
    Authors -.->|No se comunican| Books
    
    style Gateway fill:#4CAF50,stroke:#2E7D32,color:#fff
```

**Características:**
- Comunicación síncrona mediante HTTP REST
- El Gateway orquesta las llamadas
- Los microservicios no se comunican directamente entre sí

## 📁 Estructura Completa del Proyecto

```mermaid
graph TB
    subgraph Root[arquitecturaMicroServicios/]
        subgraph Services[Microservicios]
            Authors[LumenAuthorsApi/]
            Books[LumenBooksApi/]
            Gateway[LumenGatewayApi/]
        end
        
        subgraph Docs[Documentación]
            APIDocs[docs/<br/>OpenAPI/Swagger]
            ArchDoc[arquitectura.md]
            Guide[guiaEstudiante.md]
        end
        
        subgraph CI[CI/CD]
            GitHub[.github/workflows/]
            GitLab[.gitlab-ci.yml]
            Pipeline[pipeline/]
        end
        
        subgraph Scripts[Scripts de Prueba]
            TestAPI[test_api.sh]
            TestGateway[test_gateway_simple.sh]
        end
    end
    
    style Authors fill:#2196F3,stroke:#1565C0,color:#fff
    style Books fill:#FF9800,stroke:#E65100,color:#fff
    style Gateway fill:#4CAF50,stroke:#2E7D32,color:#fff
    style APIDocs fill:#9C27B0,stroke:#6A1B9A,color:#fff
    style CI fill:#F44336,stroke:#C62828,color:#fff
```

## 📦 Estructura de Componentes Detallada

```mermaid
graph TB
    subgraph GatewayComponents[Componentes del Gateway]
        Routes[Routes<br/>web.php]
        Controllers[Controllers<br/>AuthorController<br/>BookController]
        Services[Services<br/>AuthorService<br/>BookService]
        Traits[Traits<br/>ApiResponser<br/>ConsumesExternalService]
        Config[Config<br/>services.php<br/>.env]
    end
    
    subgraph AuthorsComponents[Componentes de Authors Service]
        ARoutes[Routes<br/>web.php]
        AController[AuthorController]
        AModel[Author Model<br/>Eloquent]
        ATrait[ApiResponser Trait]
        AMigrations[Migrations<br/>create_authors_table]
    end
    
    subgraph BooksComponents[Componentes de Books Service]
        BRoutes[Routes<br/>web.php]
        BController[BookController]
        BModel[Book Model<br/>Eloquent]
        BTrait[ApiResponser Trait]
        BMigrations[Migrations<br/>create_books_table]
    end
    
    Routes --> Controllers
    Controllers --> Services
    Services --> Traits
    Services --> Config
    
    ARoutes --> AController
    AController --> AModel
    AController --> ATrait
    AModel --> AMigrations
    
    BRoutes --> BController
    BController --> BModel
    BController --> BTrait
    BModel --> BMigrations
    
    style GatewayComponents fill:#4CAF50,stroke:#2E7D32,color:#fff
    style AuthorsComponents fill:#2196F3,stroke:#1565C0,color:#fff
    style BooksComponents fill:#FF9800,stroke:#E65100,color:#fff
```

## 🔐 Flujo de Validación y Manejo de Errores

```mermaid
sequenceDiagram
    participant C as Cliente
    participant G as Gateway
    participant AS as Authors Service
    participant BS as Books Service
    
    C->>G: POST /books<br/>{author_id: 999}
    
    G->>AS: GET /authors/999
    
    alt Autor no existe
        AS-->>G: 404 Not Found<br/>{error: "...", code: 404}
        G->>G: Exception Handler<br/>Captura ClientException
        G-->>C: 404 Not Found<br/>{error: "...", code: 404}
    else Autor existe
        AS-->>G: 200 OK<br/>{data: {...}}
        G->>BS: POST /books<br/>{...}
        
        alt Error en Books Service
            BS-->>G: 4xx/5xx Error
            G->>G: Exception Handler
            G-->>C: Error formateado
        else Éxito
            BS-->>G: 201 Created<br/>{data: {...}}
            G-->>C: 201 Created<br/>{data: {...}}
        end
    end
```

## 🚀 Despliegue y Escalabilidad

```mermaid
graph TB
    subgraph "Load Balancer"
        LB[Load Balancer]
    end
    
    subgraph "Gateway Instances"
        G1[Gateway Instance 1]
        G2[Gateway Instance 2]
        G3[Gateway Instance N]
    end
    
    subgraph "Authors Service Instances"
        A1[Authors Instance 1]
        A2[Authors Instance 2]
        AN[Authors Instance N]
    end
    
    subgraph "Books Service Instances"
        B1[Books Instance 1]
        B2[Books Instance 2]
        BN[Books Instance N]
    end
    
    LB --> G1
    LB --> G2
    LB --> G3
    
    G1 --> A1
    G1 --> A2
    G1 --> B1
    G1 --> B2
    
    G2 --> A1
    G2 --> AN
    G2 --> B1
    G2 --> BN
    
    style LB fill:#9C27B0,stroke:#6A1B9A,color:#fff
    style G1 fill:#4CAF50,stroke:#2E7D32,color:#fff
    style G2 fill:#4CAF50,stroke:#2E7D32,color:#fff
    style G3 fill:#4CAF50,stroke:#2E7D32,color:#fff
```

## 🔄 Pipeline CI/CD

```mermaid
graph TB
    subgraph "Repositorio"
        Code[Código Fuente]
    end
    
    subgraph "CI/CD Pipeline"
        Trigger[Push/PR Trigger]
        Validate[Validación]
        Test[Tests Unitarios]
        Integration[Tests Integración]
        Deploy[Despliegue]
    end
    
    subgraph "Validación"
        Syntax[Verificar Sintaxis PHP]
        Composer[Validar composer.json]
        Dependencies[Instalar Dependencias]
    end
    
    subgraph "Testing"
        UnitTests[PHPUnit Tests]
        Migrations[Ejecutar Migraciones]
        Coverage[Reportes Cobertura]
    end
    
    subgraph "Integración"
        StartServices[Iniciar Servicios]
        HealthCheck[Verificar Conectividad]
        IntegrationTests[Tests de Integración]
    end
    
    Code --> Trigger
    Trigger --> Validate
    Validate --> Syntax
    Validate --> Composer
    Validate --> Dependencies
    
    Validate --> Test
    Test --> UnitTests
    Test --> Migrations
    Test --> Coverage
    
    Test --> Integration
    Integration --> StartServices
    Integration --> HealthCheck
    Integration --> IntegrationTests
    
    Integration --> Deploy
    
    style Trigger fill:#9C27B0,stroke:#6A1B9A,color:#fff
    style Validate fill:#2196F3,stroke:#1565C0,color:#fff
    style Test fill:#FF9800,stroke:#E65100,color:#fff
    style Integration fill:#4CAF50,stroke:#2E7D32,color:#fff
    style Deploy fill:#F44336,stroke:#C62828,color:#fff
```

**Plataformas Soportadas:**
- **GitHub Actions**: `.github/workflows/ci.yml`
- **GitLab CI**: `.gitlab-ci.yml`

**Etapas del Pipeline:**
1. **Validación**: Verificación de sintaxis PHP y validación de dependencias
2. **Tests Unitarios**: Ejecución de PHPUnit en cada microservicio
3. **Tests de Integración**: Verificación de comunicación entre servicios
4. **Despliegue**: Despliegue manual a staging/production (GitLab)

## 📝 Resumen de Tecnologías

```mermaid
mindmap
    root((Arquitectura<br/>Microservicios))
        Framework
            Laravel Lumen 10.x
            PHP 8.2+
        Comunicación
            HTTP REST
            Guzzle HTTP Client
        Base de Datos
            SQLite
            Eloquent ORM
        Patrones
            API Gateway
            Database per Service
            Service Communication
        Características
            Respuestas JSON estandarizadas
            Manejo de excepciones
            Validación entre servicios
        CI/CD
            GitHub Actions
            GitLab CI
            PHPUnit Tests
            Tests de Integración
        Documentación
            OpenAPI/Swagger
            Swagger UI
            Diagramas Mermaid
```

## 🎯 Principios de Diseño Aplicados

1. **Separación de Responsabilidades**: Cada microservicio gestiona un dominio específico
2. **Independencia**: Cada servicio puede desplegarse y escalarse independientemente
3. **Comunicación Débilmente Acoplada**: Los servicios se comunican mediante HTTP REST
4. **Base de Datos Independiente**: Cada servicio tiene su propia base de datos
5. **Punto de Entrada Único**: El Gateway centraliza todas las peticiones
6. **Validación Centralizada**: El Gateway valida reglas de negocio entre servicios
7. **Integración Continua**: Pipeline CI/CD automatizado para validación y testing
8. **Documentación Primero**: APIs documentadas con OpenAPI/Swagger

## 📚 Documentación y Herramientas

### Documentación de APIs
- **OpenAPI 3.0**: Especificaciones completas para cada servicio
- **Swagger UI**: Interfaz interactiva para probar endpoints
- **Visualización**: Disponible en `docs/index.html`

### CI/CD Pipeline
- **Validación Automática**: Verificación de código en cada push
- **Tests Automatizados**: Ejecución de PHPUnit y tests de integración
- **Reportes**: Cobertura de código y resultados de tests

### Herramientas de Desarrollo
- **Scripts de Prueba**: `test_api.sh`, `test_gateway_simple.sh`
- **Validación Local**: `pipeline/local-test.sh`
- **Documentación**: Scripts para servir documentación localmente

---

**Nota**: Los diagramas Mermaid pueden visualizarse en editores como VS Code con la extensión "Markdown Preview Mermaid Support" o en plataformas como GitHub, GitLab, o [Mermaid Live Editor](https://mermaid.live/).
