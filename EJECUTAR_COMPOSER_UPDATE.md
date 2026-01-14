# Instrucciones para Ejecutar Composer Update

Composer no está disponible en el entorno actual. Sigue estas instrucciones para actualizar las dependencias manualmente.

## Opción 1: Si tienes Composer instalado globalmente

Ejecuta estos comandos en tu terminal:

```bash
# Navegar al directorio del proyecto
cd "/Users/xavicrip/UTPL/1. docencia/7. Octubre 25 Febrero 26/1. Arquitectura de Software/8. Practicas/arquitecturaMicroServicios"

# Actualizar Authors Service
cd LumenAuthorsApi
composer update --no-interaction
cd ..

# Actualizar Books Service
cd LumenBooksApi
composer update --no-interaction
cd ..

# Actualizar Gateway Service
cd LumenGatewayApi
composer update --no-interaction
cd ..
```

## Opción 2: Usar el script automatizado

Si tienes composer instalado, puedes usar el script que se creó:

```bash
cd "/Users/xavicrip/UTPL/1. docencia/7. Octubre 25 Febrero 26/1. Arquitectura de Software/8. Practicas/arquitecturaMicroServicios"
bash update_dependencies.sh
```

## Opción 3: Instalar Composer si no lo tienes

Si no tienes Composer instalado, puedes instalarlo así:

### macOS (usando Homebrew):
```bash
brew install composer
```

### Descarga directa:
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
```

### Verificar instalación:
```bash
composer --version
```

## Opción 4: Usar Composer local (composer.phar)

Si descargaste composer.phar localmente:

```bash
cd "/Users/xavicrip/UTPL/1. docencia/7. Octubre 25 Febrero 26/1. Arquitectura de Software/8. Practicas/arquitecturaMicroServicios"

# Authors Service
cd LumenAuthorsApi
php ../composer.phar update --no-interaction
cd ..

# Books Service
cd LumenBooksApi
php ../composer.phar update --no-interaction
cd ..

# Gateway Service
cd LumenGatewayApi
php ../composer.phar update --no-interaction
cd ..
```

## Qué esperar durante la actualización

Durante `composer update`, verás:

1. **Descarga de dependencias**: Composer descargará las nuevas versiones de los paquetes
2. **Resolución de dependencias**: Composer resolverá las dependencias compatibles
3. **Actualización de composer.lock**: Se actualizará el archivo de bloqueo
4. **Autoloader**: Se regenerará el autoloader de Composer

**Tiempo estimado**: 2-5 minutos por servicio (dependiendo de tu conexión a internet)

## Verificar que la actualización fue exitosa

Después de ejecutar `composer update`, verifica que todo esté correcto:

```bash
# En cada servicio, verifica la versión
cd LumenAuthorsApi
php artisan --version
# Debería mostrar: Lumen Framework version 10.x.x

cd ../LumenBooksApi
php artisan --version

cd ../LumenGatewayApi
php artisan --version
```

## Solución de problemas

### Error: "Your requirements could not be resolved"

Esto puede ocurrir si hay conflictos de dependencias. Intenta:

```bash
composer update --with-all-dependencies
```

### Error: "Memory limit exhausted"

Aumenta el límite de memoria de PHP:

```bash
php -d memory_limit=512M composer update
```

### Error: "SSL certificate problem"

Si tienes problemas con certificados SSL:

```bash
composer update --no-interaction --prefer-dist --no-progress
```

O configura composer para ignorar SSL:

```bash
composer config -g secure-http false
```

## Después de la actualización

Una vez completada la actualización:

1. **Verifica que los servicios funcionen**:
   ```bash
   # Inicia los servicios y prueba los endpoints
   php -S localhost:8001 -t LumenAuthorsApi/public &
   php -S localhost:8002 -t LumenBooksApi/public &
   php -S localhost:8000 -t LumenGatewayApi/public &
   
   # Prueba los endpoints
   curl http://localhost:8000/authors
   ```

2. **Revisa los logs** si hay algún error

3. **Ejecuta las migraciones** si es necesario:
   ```bash
   cd LumenAuthorsApi && php artisan migrate --force
   cd ../LumenBooksApi && php artisan migrate --force
   ```

## Notas importantes

- ⚠️ **Backup**: Antes de actualizar, considera hacer un backup de `composer.lock` y `vendor/`
- ⏱️ **Tiempo**: La actualización puede tardar varios minutos
- 🌐 **Internet**: Necesitas conexión a internet para descargar las dependencias
- 💾 **Espacio**: Asegúrate de tener suficiente espacio en disco

---

**¿Necesitas ayuda?** Revisa la documentación en [ACTUALIZACION_LUMEN10.md](ACTUALIZACION_LUMEN10.md)
