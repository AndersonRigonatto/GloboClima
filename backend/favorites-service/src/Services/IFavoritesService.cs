namespace GloboClima.Favorites.Services
{
    // Esta classe define a estrutura do objeto de favoritos que vamos salvar e recuperar
    public class FavoriteItem
    {
        public List<string> Cities { get; set; } = new List<string>();
        public List<string> Countries { get; set; } = new List<string>();
    }

    // Esta é a interface que define os métodos do nosso serviço
    public interface IFavoritesService
    {
        Task<FavoriteItem> GetFavoritesAsync(string userId);
        Task AddFavoriteCityAsync(string userId, string city);
        Task AddFavoriteCountryAsync(string userId, string country);
        Task RemoveFavoriteCityAsync(string userId, string city);
        Task RemoveFavoriteCountryAsync(string userId, string country);
    }
}