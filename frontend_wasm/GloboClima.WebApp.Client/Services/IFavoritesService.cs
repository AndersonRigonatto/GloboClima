using GloboClima.WebApp.Client.Models;
using System.Threading.Tasks;

namespace GloboClima.WebApp.Client.Services
{
    public interface IFavoritesService
    {
        Task<UserFavorites?> GetFavoritesAsync();
        Task AddFavoriteCityAsync(string city);
        Task AddFavoriteCountryAsync(string country);
        Task RemoveFavoriteCityAsync(string city);
        Task RemoveFavoriteCountryAsync(string country);
    }
}
