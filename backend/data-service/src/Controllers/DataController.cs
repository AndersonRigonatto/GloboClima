using GloboClima.Data.Services;
using Microsoft.AspNetCore.Mvc;

// Controller para dados climáticos e geográficos
namespace GloboClima.Data.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DataController : ControllerBase
    {
        private readonly IWeatherService _weatherService;
        private readonly ICountryService _countryService;

        // Nossos serviços são injetados aqui
        public DataController(IWeatherService weatherService, ICountryService countryService)
        {
            _weatherService = weatherService;
            _countryService = countryService;
        }

        [HttpGet("weather/{city}")]
        public async Task<IActionResult> GetWeather(string city)
        {
            var weatherData = await _weatherService.GetWeatherByCityAsync(city);
            if (weatherData == null)
            {
                return NotFound($"Não foi possível encontrar o clima para a cidade: {city}");
            }
            return Ok(weatherData);
        }

        [HttpGet("countries/{name}")]
        public async Task<IActionResult> GetCountry(string name)
        {
            var countryData = await _countryService.GetCountryByNameAsync(name);
            if (countryData == null)
            {
                return NotFound($"Não foi possível encontrar o país: {name}");
            }
            return Ok(countryData);
        }
    }
}