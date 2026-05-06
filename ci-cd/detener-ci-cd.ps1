$raiz = Split-Path -Parent $MyInvocation.MyCommand.Path

foreach ($servicio in @("jenkins", "tomcat", "sonarqube", "mysql")) {
    Write-Host "`n=== Deteniendo $servicio ===" -ForegroundColor Yellow
    Set-Location "$raiz\$servicio"
    docker-compose down
}

Set-Location $raiz
Write-Host "`n=== Todos los servicios detenidos ===" -ForegroundColor Green
docker ps