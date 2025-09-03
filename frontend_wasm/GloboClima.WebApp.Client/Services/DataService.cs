using GloboClima.WebApp.Client.Models;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;

namespace GloboClima.WebApp.Client.Services
{
    public class DataService : IDataService
    {
        private readonly HttpClient _httpClient;

        public DataService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<WeatherResponse?> GetWeatherAsync(string city)
        {
            try
            {
                return await _httpClient.GetFromJsonAsync<WeatherResponse>($"/api/data/weather/{city}");
            }
            catch (HttpRequestException)
            {
                return null;
            }
        }

        public async Task<List<CountryResponse>?> GetCountryAsync(string name)
        {
            try
            {
                return await _httpClient.GetFromJsonAsync<List<CountryResponse>>($"/api/data/countries/{name}");
            }
            catch (HttpRequestException)
            {
                return null;
            }
        }
    }
}
