using GloboClima.Favorites.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

// Controller para gerenciar favoritos (cidades e países)
namespace GloboClima.Favorites.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // O portão de segurança: só permite acesso com um token JWT válido
    public class FavoritesController : ControllerBase
    {
        private readonly IFavoritesService _favoritesService;

        public FavoritesController(IFavoritesService favoritesService)
        {
            _favoritesService = favoritesService;
        }

        // Helper para pegar o ID do usuário logado de dentro do token
        private string? GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        [HttpGet]
        public async Task<IActionResult> GetFavorites()
        {
            var userId = GetUserId();
            if (userId is null) return Unauthorized(); // Verificação de segurança

            var favorites = await _favoritesService.GetFavoritesAsync(userId);
            return Ok(favorites);
        }

        [HttpPost("cities/{city}")]
        public async Task<IActionResult> AddFavoriteCity(string city)
        {
            var userId = GetUserId();
            if (userId is null) return Unauthorized();

            Console.WriteLine(userId);
            Console.WriteLine(city);

            await _favoritesService.AddFavoriteCityAsync(userId, city);
            return Ok($"Cidade '{city}' adicionada aos favoritos.");
        }

        [HttpPost("countries/{country}")]
        public async Task<IActionResult> AddFavoriteCountry(string country)
        {
            var userId = GetUserId();
            if (userId is null) return Unauthorized();

            await _favoritesService.AddFavoriteCountryAsync(userId, country);
            return Ok($"País '{country}' adicionado aos favoritos.");
        }

        [HttpDelete("cities/{city}")]
        public async Task<IActionResult> RemoveFavoriteCity(string city)
        {
            var userId = GetUserId();
            if (userId is null) return Unauthorized();

            await _favoritesService.RemoveFavoriteCityAsync(userId, city);
            return Ok($"Cidade '{city}' removida dos favoritos.");
        }

        // NOVO ENDPOINT PARA DELETAR PAÍS
        [HttpDelete("countries/{country}")]
        public async Task<IActionResult> RemoveFavoriteCountry(string country)
        {
            var userId = GetUserId();
            if (userId is null) return Unauthorized();

            await _favoritesService.RemoveFavoriteCountryAsync(userId, country);
            return Ok($"País '{country}' removido dos favoritos.");
        }
    }
}