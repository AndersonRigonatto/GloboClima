using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;
using GloboClima.Auth.DTOs;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace GloboClima.Auth.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAmazonDynamoDB _dynamoDb;
        private readonly IConfiguration _configuration;
        private const string UserTableName = "GloboClimaUsers";

        public AuthService(IAmazonDynamoDB dynamoDb, IConfiguration configuration)
        {
            _dynamoDb = dynamoDb;
            _configuration = configuration;
        }

        public async Task<bool> RegisterUserAsync(UserRegisterRequest request)
        {
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            var requestItem = new PutItemRequest
            {
                TableName = UserTableName,
                Item = new Dictionary<string, AttributeValue>
                {
                    { "Username", new AttributeValue { S = request.Username } },
                    { "PasswordHash", new AttributeValue { S = passwordHash } }
                },
                ConditionExpression = "attribute_not_exists(Username)"
            };

            try
            {
                await _dynamoDb.PutItemAsync(requestItem);
                return true;
            }
            catch (ConditionalCheckFailedException)
            {
                return false;
            }
        }

        public async Task<string> LoginUserAsync(UserLoginRequest request)
        {
            var requestItem = new GetItemRequest
            {
                TableName = UserTableName,
                Key = new Dictionary<string, AttributeValue>
                {
                    { "Username", new AttributeValue { S = request.Username } }
                }
            };

            var response = await _dynamoDb.GetItemAsync(requestItem);
            if (response.Item == null || !response.Item.Any())
            {
                return null;
            }

            var passwordHashFromDb = response.Item["PasswordHash"].S;
            if (!BCrypt.Net.BCrypt.Verify(request.Password, passwordHashFromDb))
            {
                return null;
            }

            var token = GenerateJwtToken(request.Username);
            return token;
        }

        private string GenerateJwtToken(string username)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.Name, username),
                    new Claim(ClaimTypes.NameIdentifier, username)
                }),
                Expires = DateTime.UtcNow.AddHours(2),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Audience"],
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}