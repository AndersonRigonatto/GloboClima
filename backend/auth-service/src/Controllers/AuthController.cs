using GloboClima.Auth.DTOs;
using GloboClima.Auth.Services;
using Microsoft.AspNetCore.Mvc;

// Controller autenticação de usuários
namespace GloboClima.Auth.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(UserRegisterRequest request)
        {
            var success = await _authService.RegisterUserAsync(request);
            if (!success)
            {
                return BadRequest("Usuário já existe.");
            }
            return Ok("Usuário registrado com sucesso.");
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(UserLoginRequest request)
        {
            var token = await _authService.LoginUserAsync(request);
            if (token == null)
            {
                return Unauthorized("Usuário ou senha inválidos.");
            }
            return Ok(new AuthResponse(request.Username, token));
        }
    }
}