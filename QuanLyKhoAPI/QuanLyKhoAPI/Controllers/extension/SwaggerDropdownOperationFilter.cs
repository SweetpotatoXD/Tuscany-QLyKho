using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace GioiThieuCty
{
    public class SwaggerDropdownOperationFilter : IOperationFilter
    {
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            if (operation.OperationId == "PutUser")
            {
                var param = operation.Parameters.FirstOrDefault(p => p.Name == "lastModifiedBy");
                if (param != null)
                {
                    param.Description = "Enter the ID of an admin user. Use GET /api/User/admin-dropdown to fetch a list of admin IDs and usernames.";
                    param.Schema.Type = "integer";
                }
            }
        }
    }
}