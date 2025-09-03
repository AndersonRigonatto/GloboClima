using GloboClima.WebApp.Client.Models;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;

namespace GloboClima.WebApp.Client.Services
{
    public class FavoritesService : IFavoritesService
    {
        private readonly HttpClient _httpClient;

        public FavoritesService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<UserFavorites?> GetFavoritesAsync()
        {
            try
            {
                return await _httpClient.GetFromJsonAsync<UserFavorites>("/api/favorites");
            }
            catch (HttpRequestException)
            {
                return null;
            }
        }

        public async Task AddFavoriteCityAsync(string city)
        {
            await _httpClient.PostAsync($"/api/favorites/cities/{city}", null);
        }

        public async Task AddFavoriteCountryAsync(string country)
        {
            await _httpClient.PostAsync($"/api/favorites/countries/{country}", null);
        }

        public async Task RemoveFavoriteCityAsync(string city)
        {
            await _httpClient.DeleteAsync($"/api/favorites/cities/{city}");
        }

        public async Task RemoveFavoriteCountryAsync(string country)
        {
            await _httpClient.DeleteAsync($"/api/favorites/countries/{country}");
        }
    }
}
