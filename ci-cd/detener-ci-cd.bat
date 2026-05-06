@echo off
set RAIZ=%~dp0

for %%S in (jenkins tomcat sonarqube mysql) do (
    echo.
    echo === Deteniendo %%S ===
    cd /d "%RAIZ%%%S"
    docker-compose down
)

echo.
echo === Todos los servicios detenidos ===
docker ps
pause