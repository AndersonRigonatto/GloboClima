using GloboClima.Data.DTOs;
using System.Text.Json;

namespace GloboClima.Data.Services
{
    public class WeatherService : IWeatherService
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly string _apiKey;

        // Usamos injeção de dependência para receber as ferramentas que precisamos
        public WeatherService(IHttpClientFactory httpClientFactory, IConfiguration configuration)
        {
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _apiKey = _configuration["OpenWeather:ApiKey"]; // Pega a chave do appsettings.json
        }

        public async Task<WeatherResponse> GetWeatherByCityAsync(string city)
        {
            var client = _httpClientFactory.CreateClient();
            var url = $"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={_apiKey}&units=metric&lang=pt_br";

            var response = await client.GetAsync(url);

            if (response.IsSuccessStatusCode)
            {
                var jsonString = await response.Content.ReadAsStringAsync();
                // Converte a string JSON para o nosso objeto C#
                var weatherResponse = JsonSerializer.Deserialize<WeatherResponse>(jsonString);
                return weatherResponse;
            }

            return null; // ou lançar uma exceção
        }
    }
}