# CI/CD Pipeline Documentation

Este directorio contiene la documentación y configuración de los pipelines de CI/CD para el proyecto de arquitectura de microservicios.

## 📋 Pipelines Disponibles

### GitHub Actions
- **Archivo**: `.github/workflows/ci.yml`
- **Plataforma**: GitHub
- **Características**:
  - Validación de código PHP
  - Ejecución de tests unitarios
  - Pruebas de integración
  - Validación de documentación OpenAPI

### GitLab CI
- **Archivo**: `.gitlab-ci.yml`
- **Plataforma**: GitLab
- **Características**:
  - Múltiples stages (validate, test, integration, deploy)
  - Cache de dependencias
  - Coverage reports
  - Deploy manual a staging/production

## 🚀 Uso de los Pipelines

### GitHub Actions

El pipeline se ejecuta automáticamente cuando:
- Se hace push a las ramas `main`, `master` o `develop`
- Se crea o actualiza un Pull Request

**Ver el estado del pipeline:**
1. Ve a la pestaña "Actions" en tu repositorio de GitHub
2. Selecciona el workflow "CI Pipeline - Microservicios"
3. Revisa los resultados de cada job

### GitLab CI

El pipeline se ejecuta automáticamente cuando:
- Se hace push a las ramas `main`, `master` o `develop`
- Se crea o actualiza un Merge Request

**Ver el estado del pipeline:**
1. Ve a "CI/CD" > "Pipelines" en tu proyecto de GitLab
2. Selecciona el pipeline que quieres revisar
3. Revisa los resultados de cada stage

## 📦 Jobs del Pipeline

### 1. Validación (Validate)
- ✅ Valida `composer.json`
- ✅ Instala dependencias
- ✅ Verifica sintaxis PHP
- ✅ Ejecuta en paralelo para cada servicio

### 2. Tests Unitarios (Test)
- ✅ Ejecuta PHPUnit en cada servicio
- ✅ Ejecuta migraciones de base de datos
- ✅ Genera reportes de cobertura (GitLab)
- ✅ Ejecuta en paralelo para cada servicio

### 3. Tests de Integración (Integration)
- ✅ Inicia todos los servicios
- ✅ Verifica conectividad entre servicios
- ✅ Ejecuta scripts de prueba de integración
- ✅ Valida el funcionamiento del Gateway

### 4. Despliegue (Deploy) - Solo GitLab
- ✅ Deploy manual a staging (desde `develop`)
- ✅ Deploy manual a production (desde `main`/`master`)

## 🔧 Configuración

### Variables de Entorno

#### GitHub Actions
Las variables se configuran directamente en el workflow o en:
- Settings > Secrets and variables > Actions

#### GitLab CI
Configurar variables en:
- Settings > CI/CD > Variables

**Variables recomendadas:**
```bash
# URLs de servicios (para tests de integración)
AUTHORS_SERVICE_BASE_URL=http://localhost:8001
BOOKS_SERVICE_BASE_URL=http://localhost:8002
GATEWAY_SERVICE_BASE_URL=http://localhost:8000

# Base de datos (para tests)
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

### Personalizar el Pipeline

#### Agregar Nuevos Tests

1. **Tests Unitarios**: Agrega tests en `tests/` de cada servicio
2. **Tests de Integración**: Modifica los scripts en la raíz del proyecto

#### Agregar Nuevos Servicios

1. Copia un job existente (ej: `authors-service`)
2. Cambia el `working-directory` al nuevo servicio
3. Ajusta las variables de entorno si es necesario

#### Agregar Deploy Automático

1. Agrega credenciales como secrets
2. Agrega comandos de deploy en el stage correspondiente
3. Configura condiciones (ej: solo en `main`)

## 📊 Reportes y Artefactos

### GitHub Actions
- Los resultados se muestran en la pestaña "Actions"
- Los logs están disponibles para cada job

### GitLab CI
- **Coverage Reports**: Disponibles en la pestaña "Coverage"
- **JUnit Reports**: Disponibles en "Test Reports"
- **Artifacts**: Descargables desde la página del pipeline

## 🐛 Troubleshooting

### El pipeline falla en "Install dependencies"

**Problema**: Error al instalar dependencias de Composer

**Solución**:
- Verifica que `composer.json` sea válido
- Revisa que todas las dependencias estén disponibles
- Verifica la versión de PHP (debe ser 8.1+)

### El pipeline falla en "Integration Tests"

**Problema**: Los servicios no inician correctamente

**Solución**:
- Verifica que los puertos no estén en uso
- Aumenta el tiempo de espera (`sleep`)
- Revisa los logs en `/tmp/*.log`

### Tests fallan por base de datos

**Problema**: Error de conexión a base de datos

**Solución**:
- Verifica que SQLite esté disponible
- Usa `:memory:` para tests
- Verifica las variables de entorno

## 📚 Recursos Adicionales

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [Composer Documentation](https://getcomposer.org/doc/)

## 🔄 Mejores Prácticas

1. **Ejecutar tests localmente antes de hacer push**
   ```bash
   cd LumenAuthorsApi && vendor/bin/phpunit
   ```

2. **Mantener los pipelines rápidos**
   - Usa cache cuando sea posible
   - Ejecuta jobs en paralelo
   - Evita dependencias innecesarias

3. **Revisar los resultados del pipeline**
   - Corrige errores antes de mergear
   - Revisa los reportes de cobertura
   - Mantén los tests actualizados

4. **Documentar cambios en el pipeline**
   - Actualiza este README cuando hagas cambios
   - Documenta nuevas variables de entorno
   - Explica cambios en la configuración

## 🎯 Próximos Pasos

- [ ] Agregar tests de carga/performance
- [ ] Implementar análisis estático de código (PHPStan, Psalm)
- [ ] Agregar notificaciones (Slack, Email)
- [ ] Configurar deploy automático a staging
- [ ] Agregar tests de seguridad (OWASP)
