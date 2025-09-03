using GloboClima.WebApp.Client.Models;
using System.Threading.Tasks;

namespace GloboClima.WebApp.Client.Services
{
    public interface IDataService
    {
        Task<WeatherResponse?> GetWeatherAsync(string city);
        Task<List<CountryResponse>?> GetCountryAsync(string name);
    }
}
