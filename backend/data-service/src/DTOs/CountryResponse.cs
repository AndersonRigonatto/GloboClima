using System.Text.Json.Serialization;

namespace GloboClima.Data.DTOs
{
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