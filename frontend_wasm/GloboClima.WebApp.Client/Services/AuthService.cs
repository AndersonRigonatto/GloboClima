using GloboClima.WebApp.Client.Models;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;

namespace GloboClima.WebApp.Client.Services
{
    public class AuthService : IAuthService
    {
        private readonly HttpClient _httpClient;

        public AuthService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<AuthResponse?> LoginAsync(UserLoginRequest request)
        {
            var response = await _httpClient.PostAsJsonAsync("/api/auth/login", request);
            if (response.IsSuccessStatusCode)
            {
                return await response.Content.ReadFromJsonAsync<AuthResponse>();
            }
            return null;
        }

        public async Task<bool> RegisterAsync(UserRegisterRequest request)
        { 
            var response = await _httpClient.PostAsJsonAsync("/api/auth/register", request);
            return response.IsSuccessStatusCode;
        }
    }
}
