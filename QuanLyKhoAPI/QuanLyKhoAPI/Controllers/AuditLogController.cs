using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using GioiThieuCty.Data;
using GioiThieuCty.Models.DB;
using Microsoft.Data.SqlClient;
using GioiThieuCty.Models.objResponse;
using System.Data;

namespace GioiThieuCty.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuditLogController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;
        private readonly ILogger<AuditLogController> _logger;

        public AuditLogController(GioiThieuCtyContext context, ILogger<AuditLogController> logger)
        {
            _context = context;
            _logger = logger;
        }
        /*public int Id { get; set; }
        public DateTime? Time { get; set; }
        public string? Operation { get; set; }
        public string? ChangeSource { get; set; }
        public string? Users { get; set; }
        public string? TableName { get; set; }
        public string? TableId { get; set; }
        public string? FieldChanges { get; set; }
        public string? Data { get; set; }*/
        [HttpGet]
        public async Task<ActionResult<ResultT<List<AuditLog>>>> GetAuditLog(
            int? Id,
            DateTime? Time,
            string? Operation,
            string? ChangeSource,
            string? Users,
            string? TableName,
            string? TableId,
            string? FieldChanges,
            string? Data)
        {
            string httpMethod = HttpContext.Request.Method;
            try
            {
                var parameters = new[]
                {
                    new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                    new SqlParameter("@Time",(object)Time?? DBNull.Value),
                    new SqlParameter("@Operation", (object)Operation ?? DBNull.Value),
                    new SqlParameter("@ChangeSource",(object)ChangeSource?? DBNull.Value),
                    new SqlParameter("@Users",(object)Users?? DBNull.Value),
                    new SqlParameter("@TableName", (object)TableName ?? DBNull.Value),
                    new SqlParameter("@TableId", (object)TableId ?? DBNull.Value),
                    new SqlParameter("@FieldChanges", (object)FieldChanges ?? DBNull.Value),
                    new SqlParameter("@UsersId", (object)Data ?? DBNull.Value)
                };

                // Capture SQL messages
                var messages = new List<string>();
                string connectionString = _context.Database.GetDbConnection().ConnectionString;
                using (var connection = new SqlConnection(connectionString))
                {
                    await connection.OpenAsync();
                    var command = new SqlCommand("AuditLog_Read", connection)
                    {
                        CommandType = CommandType.StoredProcedure
                    };
                    foreach (var param in parameters)
                    {
                        command.Parameters.Add(param);
                    }
                    connection.InfoMessage += (sender, e) => messages.Add(e.Message);
                    await command.ExecuteNonQueryAsync();
                }

                var result = await _context.AuditLog.FromSqlRaw(
                    $"EXEC AuditLog_Read @Id, @Operation, @TableName, @UsersId",
                    parameters).ToListAsync();

                // Log SQL messages
                if (messages.Any())
                {
                    _logger.LogInformation("SQL Messages: {SqlMessages}", string.Join("; ", messages));
                }

                _logger.LogInformation("[{HttpMethod}] -(Success) {{Id: {Id}, UsersId: {UsersId}}}, SQL Messages: {SqlMessages}",
                    httpMethod, Id, string.Join("; ", messages));

                if (result.Any())
                {
                    return Ok(new ResultT<List<AuditLog>>
                    {
                        IsSuccess = true,
                        ErrorMessage = null,
                        Count = result.Count,
                        Data = result
                    });
                }

                _logger.LogWarning("[{HttpMethod}] -(Not found) {{Id: {Id}}}, SQL Messages: {SqlMessages}",
                    httpMethod, Id, string.Join("; ", messages));
                return NotFound(new ResultT<List<AuditLog>>
                {
                    IsSuccess = false,
                    ErrorMessage = "AuditLog not found",
                    Count = 0,
                    Data = null
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{HttpMethod}] -(Exception: {ExceptionMessage}) {{Id: {Id}}}",
                    httpMethod, ex.Message, Id);
                return StatusCode(500, new ResultT<List<AuditLog>>
                {
                    IsSuccess = false,
                    ErrorMessage = "An error occurred while retrieving the AuditLog.",
                    Count = 0,
                    Data = null
                });
            }
        }
    }
}