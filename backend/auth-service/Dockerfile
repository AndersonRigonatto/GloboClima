# Estágio 1: Build
# Usamos a imagem do SDK do .NET para compilar a aplicação
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copia o arquivo .csproj e restaura as dependências primeiro
# <--- MUDANÇA AQUI: Apontamos para a pasta "src"
COPY ["src/GloboClima.Auth.csproj", "src/"]

# Restaura as dependências do projeto
# <--- MUDANÇA AQUI: Apontamos para a pasta "src"
RUN dotnet restore "src/GloboClima.Auth.csproj"

# Copia o resto do código-fonte e publica a aplicação
# <--- MUDANÇA AQUI: Apontamos para a pasta "src"
COPY ["src/", "src/"]
WORKDIR "/app/src"
# <--- MUDANÇA AQUI: Apontamos para a pasta "src"
RUN dotnet publish "GloboClima.Auth.csproj" -c Release -o /app/out

# Estágio 2: Runtime
# Usamos a imagem menor do ASP.NET, que só tem o necessário para rodar
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
# Permitir que a aplicação escute de qualquer IP
ENV ASPNETCORE_URLS=http://+:5000

EXPOSE 5000

# Define o comando que será executado quando o contâiner iniciar
# Nenhuma mudança aqui, pois o nome do .dll não mudou
ENTRYPOINT ["dotnet", "GloboClima.Auth.dll"]