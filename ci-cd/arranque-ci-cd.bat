@echo off
:: arranque-ci-cd.bat
:: Ejecutar desde la carpeta raíz ci-cd/

setlocal
set RAIZ=%~dp0

echo.
echo === Verificando red network_jenkins ===
docker network ls --filter name=network_jenkins --format "{{.Name}}" | findstr /I "network_jenkins" >nul 2>&1
if errorlevel 1 (
    echo Creando red network_jenkins...
    docker network create network_jenkins
) else (
    echo Red network_jenkins ya existe, continuando...
)

echo.
echo === Levantando MySQL ===
cd /d "%RAIZ%mysql"
docker-compose up -d
if errorlevel 1 ( echo ERROR en MySQL & pause & exit /b 1 )
echo Esperando 20s para que MySQL inicialice...
timeout /t 20 /nobreak >nul

echo.
echo === Levantando SonarQube ===
cd /d "%RAIZ%sonarqube"
docker-compose up -d
if errorlevel 1 ( echo ERROR en SonarQube & pause & exit /b 1 )
echo Esperando 40s para que SonarQube inicialice...
timeout /t 40 /nobreak >nul

echo.
echo === Levantando Tomcat ===
cd /d "%RAIZ%tomcat"
docker-compose up -d
if errorlevel 1 ( echo ERROR en Tomcat & pause & exit /b 1 )
echo Esperando 15s para que Tomcat inicialice...
timeout /t 15 /nobreak >nul

echo.
echo === Levantando Jenkins ===
cd /d "%RAIZ%jenkins"
docker-compose up -d
if errorlevel 1 ( echo ERROR en Jenkins & pause & exit /b 1 )

echo.
echo === Todos los servicios levantados ===
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo === URLs disponibles ===
echo Jenkins:   http://localhost:9080
echo SonarQube: http://localhost:9001
echo Tomcat:    http://localhost:8080
echo MySQL:     localhost:3306

echo.
pause