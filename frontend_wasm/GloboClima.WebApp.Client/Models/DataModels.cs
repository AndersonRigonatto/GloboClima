using System.Text.Json.Serialization;

namespace GloboClima.WebApp.Client.Models
{
    // Weather Models
    public class WeatherResponse
    {
        [JsonPropertyName("main")]
        public MainInfo? Main { get; set; }

        [JsonPropertyName("weather")]
        public List<WeatherInfo>? Weather { get; set; }

        [JsonPropertyName("name")]
        public string? CityName { get; set; }
    }

    public class MainInfo
    {
        [JsonPropertyName("temp")]
        public double? Temperature { get; set; }
    }

    public class WeatherInfo
    {
        [JsonPropertyName("description")]
        public string? Description { get; set; }
    }

    // Country Models
    public class CountryResponse
    {
        [JsonPropertyName("name")]
        public CountryName? Name { get; set; }

        [JsonPropertyName("population")]
        public long Population { get; set; }

        [JsonPropertyName("currencies")]
        public Dictionary<string, CurrencyInfo>? Currencies { get; set; }

        [JsonPropertyName("languages")]
        public Dictionary<string, string>? Languages { get; set; }
    }

    public class CountryName
    {
        [JsonPropertyName("common")]
        public string? Common { get; set; }
    }

    public class CurrencyInfo
    {
        [JsonPropertyName("name")]
        public string? Name { get; set; }

        [JsonPropertyName("symbol")]
        public string? Symbol { get; set; }
    }
}
