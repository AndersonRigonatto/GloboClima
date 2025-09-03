using System.Text.Json.Serialization;

namespace GloboClima.Data.DTOs
{
    // Classe principal para a resposta completa
    public class WeatherResponse
    {
        [JsonPropertyName("main")]
        public MainInfo? Main { get; set; }

        [JsonPropertyName("weather")]
        public List<WeatherInfo>? Weather { get; set; }

        [JsonPropertyName("name")]
        public string? CityName { get; set; }
    }

    // Classe para a seção "main" do JSON
    public class MainInfo
    {
        [JsonPropertyName("temp")]
        public double? Temperature { get; set; }
    }

    // Classe para a seção "weather" (que é uma lista)
    public class WeatherInfo
    {
        [JsonPropertyName("description")]
        public string? Description { get; set; }
    }
}