using GloboClima.WebApp.Client.Models;
using System.Threading.Tasks;

namespace GloboClima.WebApp.Client.Services
{
    public interface IAuthService
    {
        Task<AuthResponse?> LoginAsync(UserLoginRequest request);
        Task<bool> RegisterAsync(UserRegisterRequest request);
    }
}
