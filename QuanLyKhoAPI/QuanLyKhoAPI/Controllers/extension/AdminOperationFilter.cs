using GioiThieuCty.Models.DB;
using GioiThieuCty.Models.objResponse;
using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

public class AdminOperationFilter : IOperationFilter
{
    private readonly List<string> _adminIds;
    private readonly string _apiBaseUrl;

    public AdminOperationFilter(IConfiguration configuration)
    {
        _apiBaseUrl = configuration["ApiBaseUrl"] ?? "https://localhost:7084/";
        _adminIds = FetchAdminIdsAsync().GetAwaiter().GetResult();
    }

    private async Task<List<string>> FetchAdminIdsAsync()
    { 
        try
        {
            using var client = new HttpClient();
            var response = await client.GetAsync($"{_apiBaseUrl}/api/User/dropdown");
            response.EnsureSuccessStatusCode();
            var json = await response.Content.ReadAsStringAsync();
            var data = JsonSerializer.Deserialize<ResultT<List<Admin>>>(json);
            return data?.Data?.Select(x => x.Id.ToString())?.ToList() ?? new List<string>();
        }
        catch
        {
            return new List<string>();
        }
    }

    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        var lastModifiedByParam = operation.Parameters
            ?.FirstOrDefault(p => p.Name == "lastModifiedBy" && p.In == ParameterLocation.Query);

        if (lastModifiedByParam != null)
        {
            lastModifiedByParam.Schema.Enum = _adminIds.Select(id => new OpenApiString(id))
                                                      .Cast<IOpenApiAny>()
                                                      .ToList();
            lastModifiedByParam.Description = "Select an admin ID for lastModifiedBy";
            lastModifiedByParam.Schema.Type = "integer";
        }
    }
}