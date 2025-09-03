using System.Collections.Generic;

namespace GloboClima.WebApp.Client.Models
{
    public class UserFavorites
    {
        public List<string> Cities { get; set; } = new();
        public List<string> Countries { get; set; } = new();
    }
}
