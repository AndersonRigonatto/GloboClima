using Amazon.DynamoDBv2;
using GloboClima.Favorites.Services; // Ajuste para o seu namespace
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

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

// Adicionar serviços ao contêiner.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    // Define as informações de segurança (Security Definition)
    options.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Description = "Insira o token JWT no formato: Bearer {seu_token}"
    });

    // Adiciona o requisito de seguran�a (Security Requirement)
    options.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

// 1. Configurar o serviço de favoritos
builder.Services.AddScoped<IFavoritesService, FavoritesService>();

// 2. Configurar o AWS SDK
builder.Services.AddDefaultAWSOptions(builder.Configuration.GetAWSOptions());
builder.Services.AddAWSService<IAmazonDynamoDB>();

// 3. Configurar a autenticação com JWT
var key = Encoding.ASCII.GetBytes(builder.Configuration["Jwt:Key"]);
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = false,
        ValidateAudience = false
    };
});

// Configurar o Health Check. Ele também usará a cadeia de provedores padrão.
builder.Services.AddHealthChecks().AddDynamoDb();

var app = builder.Build();

// Configurar o pipeline de requisi��es HTTP.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// <<< ADICIONAR ISSO (Passo 2: Ativar o CORS e HTTPS na ordem correta) >>>
app.UseHttpsRedirection();
app.UseCors(myAllowSpecificOrigins);
// <<< FIM DA ADIÇÃO >>>


// EXPOR O ENDPOINT /healthz
app.MapHealthChecks("/healthz");

// Middlewares de Autentica��o e Autoriza��o
// Devem vir antes do MapControllers
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();