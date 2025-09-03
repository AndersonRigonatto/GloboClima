using GloboClima.Data.DTOs;

namespace GloboClima.Data.Services
{
    public interface IWeatherService
    {
        Task<WeatherResponse> GetWeatherByCityAsync(string city);
    }
}