namespace GloboClima.WebApp.Client.Models
{
    public record UserLoginRequest(string Username, string Password);
    public record UserRegisterRequest(string Username, string Password);
    public record AuthResponse(string Username, string Token);
}
