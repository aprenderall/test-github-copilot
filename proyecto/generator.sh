# generator.sh - Script de generación para ProyNetAPI
# Autor: drincast
# Fecha: 2025-07-05
# Descripción: Este script automatiza tareas para el proyecto ProyNetAPI.

/bin/bash

#verificar que se ha proporcianado nombre del proyecto
if [ -z "$1" ]; then
  echo "Error: Debes proporcionar el nombre del proyecto."
  echo "Uso: $0 <nombre_del_proyecto>"
  exit 1
fi

PROJECT_NAME=$1

# Crea un proyecto de minimal api de .net 9
echo "Creando proyecto de minimal API..."
dotnet new webapi -n $PROJECT_NAME --no-https --framework net9.0

#Crea un proyecto de pruebas para el proyecto de minimal api de .net
echo "Creando proyecto de pruebas..."
dotnet new xunit -n ${PROJECT_NAME}.Tests --framework net9.0

# Asicia los dos proyectos
echo "Asociando proyectos..."
dotnet sln add $PROJECT_NAME/$PROJECT_NAME.csproj
dotnet sln add ${PROJECT_NAME}.Tests/${PROJECT_NAME}.Tests.csproj
# Añade las referencias necesarias
echo "Añadiendo referencias..."
dotnet add ${PROJECT_NAME}.Tests/${PROJECT_NAME}.Tests.csproj reference $PROJECT_NAME/$PROJECT_NAME.csproj

# cRea un archivo de solucion
echo "Creando archivo de solución..."
dotnet new sln -n $PROJECT_NAME

# Añade los proyectos a la solución
echo "Añadiendo proyectos a la solución..."
dotnet sln $PROJECT_NAME.sln add $PROJECT_NAME/$PROJECT_NAME.csproj
dotnet sln $PROJECT_NAME.sln add ${PROJECT_NAME}.Tests/${PROJECT_NAME}.Tests.csproj

# Añade los paquetes necesarios para el proyecto de pruebas
echo "Añadiendo paquetes necesarios para el proyecto de pruebas..."
dotnet add ${PROJECT_NAME}.Tests/${PROJECT_NAME}.Tests.csproj package Microsoft.AspNetCore.Mvc.Testing
dotnet add ${PROJECT_NAME}.Tests/${PROJECT_NAME}.Tests.csproj package MiniValidation

# Añade un archivo de docker ene le proyecto de minimal api
echo "Creando Dockerfile..."
cat <<EOL > $PROJECT_NAME/Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet build -c Release -o out

#expone el puerto 8080
EXPOSE 8080

#ejecuta la aplicacion
ENTRYPOINT ["dotnet", "${PROJECT_NAME}.dll"]
EOL

echo "Generación completada. Proyecto $PROJECT_NAME listo para usar."
echo "continua."