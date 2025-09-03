using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;
using System.Text.Json;

namespace GloboClima.Favorites.Services
{
    public class FavoritesService : IFavoritesService
    {
        private readonly IAmazonDynamoDB _dynamoDb;
        private const string TableName = "GloboClimaFavorites";

        public FavoritesService(IAmazonDynamoDB dynamoDb)
        {
            _dynamoDb = dynamoDb;
        }

        public async Task<FavoriteItem> GetFavoritesAsync(string userId)
        {
            // Usando o cliente de baixo nível para buscar um item
            var request = new GetItemRequest
            {
                TableName = TableName,
                Key = new Dictionary<string, AttributeValue>
                {
                    { "UserId", new AttributeValue { S = userId } }
                }
            };

            var response = await _dynamoDb.GetItemAsync(request);

            if (response.Item == null || !response.Item.Any())
            {
                return new FavoriteItem();
            }

            // A conversão do resultado é um pouco mais manual
            var item = new FavoriteItem();
            if (response.Item.TryGetValue("Cities", out var citiesAttr))
            {
                item.Cities = citiesAttr.SS; // SS significa String Set (Conjunto de Strings)
            }
            if (response.Item.TryGetValue("Countries", out var countriesAttr))
            {
                item.Countries = countriesAttr.SS;
            }

            return item;
        }

        public async Task AddFavoriteCityAsync(string userId, string city)
        {
            // Usando o cliente de baixo nível para atualizar um item
            var request = new UpdateItemRequest
            {
                TableName = TableName,
                // A chave do item que queremos atualizar
                Key = new Dictionary<string, AttributeValue>
                {
                    { "UserId", new AttributeValue { S = userId } }
                },
                // A instrução de atualização
                UpdateExpression = "ADD Cities :city",
                // Os valores para os placeholders na expressão
                ExpressionAttributeValues = new Dictionary<string, AttributeValue>
                {
                    { ":city", new AttributeValue { SS = new List<string> { city } } }
                }
            };

            await _dynamoDb.UpdateItemAsync(request);
        }

        public async Task AddFavoriteCountryAsync(string userId, string country)
        {
            var request = new UpdateItemRequest
            {
                TableName = TableName,
                Key = new Dictionary<string, AttributeValue>
                {
                    { "UserId", new AttributeValue { S = userId } }
                },
                UpdateExpression = "ADD Countries :country",
                ExpressionAttributeValues = new Dictionary<string, AttributeValue>
                {
                    { ":country", new AttributeValue { SS = new List<string> { country } } }
                }
            };

            await _dynamoDb.UpdateItemAsync(request);
        }

        public async Task RemoveFavoriteCityAsync(string userId, string city)
        {
            var request = new UpdateItemRequest
            {
                TableName = TableName,
                Key = new Dictionary<string, AttributeValue>
            {
                { "UserId", new AttributeValue { S = userId } }
            },
                // A instrução de atualização agora é "DELETE"
                UpdateExpression = "DELETE Cities :city",
                ExpressionAttributeValues = new Dictionary<string, AttributeValue>
            {
                { ":city", new AttributeValue { SS = new List<string> { city } } }
            }
            };
            await _dynamoDb.UpdateItemAsync(request);
        }

        // NOVO MÉTODO PARA REMOVER PAÍS
        public async Task RemoveFavoriteCountryAsync(string userId, string country)
        {
            var request = new UpdateItemRequest
            {
                TableName = TableName,
                Key = new Dictionary<string, AttributeValue>
            {
                { "UserId", new AttributeValue { S = userId } }
            },
                UpdateExpression = "DELETE Countries :country",
                ExpressionAttributeValues = new Dictionary<string, AttributeValue>
            {
                { ":country", new AttributeValue { SS = new List<string> { country } } }
            }
            };
            await _dynamoDb.UpdateItemAsync(request);
        }
    }
}