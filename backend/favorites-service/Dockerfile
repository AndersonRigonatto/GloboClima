# Estágio 1: Build
# Usamos a imagem do SDK do .NET para compilar a aplicação
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copia o arquivo .csproj e restaura as dependências primeiro
COPY ["src/GloboClima.Favorites.csproj", "src/"]

# Restaura as dependências do projeto
RUN dotnet restore "src/GloboClima.Favorites.csproj"

# Copia o resto do código-fonte e publica a aplicação
COPY ["src/", "src/"]
WORKDIR "/app/src"
RUN dotnet publish "GloboClima.Favorites.csproj" -c Release -o /app/out

# Estágio 2: Runtime
# Usamos a imagem menor do ASP.NET, que só tem o necessário para rodar
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .

ENV ASPNETCORE_URLS=http://+:5000

EXPOSE 5000

# Define o comando que será executado quando o contêiner iniciar
ENTRYPOINT ["dotnet", "GloboClima.Favorites.dll"]
