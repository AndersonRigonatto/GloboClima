using GloboClima.Data.DTOs;
using System.Text.Json;

namespace GloboClima.Data.Services
{
    public class CountryService : ICountryService
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public CountryService(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        public async Task<List<CountryResponse>> GetCountryByNameAsync(string name)
        {
            var client = _httpClientFactory.CreateClient();
            var url = $"https://restcountries.com/v3.1/name/{name}";

            var response = await client.GetAsync(url);

            if (response.IsSuccessStatusCode)
            {
                var jsonString = await response.Content.ReadAsStringAsync();
                var countryResponse = JsonSerializer.Deserialize<List<CountryResponse>>(jsonString);
                return countryResponse;
            }

            return null;
        }
    }
}