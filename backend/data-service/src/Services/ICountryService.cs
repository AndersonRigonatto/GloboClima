using GloboClima.Data.DTOs;

namespace GloboClima.Data.Services
{
    public interface ICountryService
    {
        Task<List<CountryResponse>> GetCountryByNameAsync(string name);
    }
}