# arranque-ci-cd.ps1
# Ejecutar desde la carpeta raíz ci-cd/
# PowerShell: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent $MyInvocation.MyCommand.Path

function Levantar($servicio) {
    Write-Host "`n=== Levantando $servicio ===" -ForegroundColor Cyan
    Set-Location "$raiz\$servicio"
    docker-compose up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR al levantar $servicio" -ForegroundColor Red
        exit 1
    }
    Set-Location $raiz
}

# 1. Verificar que la red existe
Write-Host "`n=== Verificando red network_jenkins ===" -ForegroundColor Cyan
$red = docker network ls --filter name=network_jenkins --format "{{.Name}}"
if ($red -ne "network_jenkins") {
    Write-Host "Creando red network_jenkins..."
    docker network create network_jenkins
} else {
    Write-Host "Red network_jenkins ya existe, continuando..."
}

# 2. Levantar en orden
Levantar "mysql"
Write-Host "Esperando 20s para que MySQL inicialice..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Levantar "sonarqube"
Write-Host "Esperando 40s para que SonarQube inicialice..." -ForegroundColor Yellow
Start-Sleep -Seconds 40

Levantar "tomcat"
Write-Host "Esperando 15s para que Tomcat inicialice..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Levantar "jenkins"

# 3. Estado final
Write-Host "`n=== Todos los servicios levantados ===" -ForegroundColor Green
docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"

Write-Host "`n=== URLs disponibles ===" -ForegroundColor Green
Write-Host "Jenkins:   http://localhost:9080"
Write-Host "SonarQube: http://localhost:9001"
Write-Host "Tomcat:    http://localhost:8080"
Write-Host "MySQL:     localhost:3306"