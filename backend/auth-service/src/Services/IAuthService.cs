using GloboClima.Auth.DTOs;

namespace GloboClima.Auth.Services
{
    public interface IAuthService
    {
        Task<bool> RegisterUserAsync(UserRegisterRequest request);
        Task<string> LoginUserAsync(UserLoginRequest request);
    }
}