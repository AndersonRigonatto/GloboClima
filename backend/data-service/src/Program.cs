using GloboClima.Data.Services; // Ajuste para o seu namespace

var builder = WebApplication.CreateBuilder(args);

// <<< ADICIONAR ISSO (Passo 1: Definir e registrar a política de CORS) >>>
var myAllowSpecificOrigins = "_myAllowSpecificOrigins";
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: myAllowSpecificOrigins,
                      policy  =>
                      {
                          policy.AllowAnyOrigin()
                                .AllowAnyHeader()
                                .AllowAnyMethod();
                      });
});
// <<< FIM DA ADIÇÃO >>>

// Adicionar servi�os ao cont�iner.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 1. Configurar o HttpClientFactory
builder.Services.AddHttpClient();

// 2. Registrar os servi�os de dados
builder.Services.AddScoped<ICountryService, CountryService>();
builder.Services.AddScoped<IWeatherService, WeatherService>();

// 1. Configurar o Health Check básico. 
//    Ele verifica apenas se o próprio serviço está de pé.
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configurar o pipeline de requisi��es HTTP.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// 2. EXPOR O ENDPOINT /healthz
app.MapHealthChecks("/healthz");

// <<< ADICIONAR ESTA LINHA AQUI (Passo 2) >>>
// Ativar o CORS antes da Autorização
app.UseCors(myAllowSpecificOrigins);
// <<< FIM DA ADIÇÃO >>>

app.UseAuthorization();

app.MapControllers();

app.Run();