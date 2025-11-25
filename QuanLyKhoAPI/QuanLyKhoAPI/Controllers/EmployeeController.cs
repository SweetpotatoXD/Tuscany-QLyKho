using GioiThieuCty.Data;
using GioiThieuCty.Models.DB;
using GioiThieuCty.Models.objResponse;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

namespace GioiThieuCty.Controllers
{
    [Route("api/Employee/[controller]")]
    [ApiController]
    public class EmployeeController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;
        private readonly ILogger<EmployeeController> _logger;

        public EmployeeController(GioiThieuCtyContext context, ILogger<EmployeeController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpPost]
        public async Task<ActionResult<ResultT<List<Employee>>>> CreateNewEmployee(
            string? Name,
            string? Role,
            string? PhoneNumber,
            string? Email,
            string? Address,
            string? CreatedBy)
                {
            string httpMethod = HttpContext.Request.Method;

            try
            {
                // ======= VALIDATION ========
                if (string.IsNullOrWhiteSpace(Name) || string.IsNullOrWhiteSpace(Email))
                {
                    _logger.LogError("[{HttpMethod}] (Validation failed) {{Name: {Name}, Email: {Email}}}",
                        httpMethod, Name ?? "null", Email ?? "null");

                    return BadRequest(new ResultT<List<Employee>>
                    {
                        IsSuccess = false,
                        ErrorMessage = "Name and Email are required.",
                        Count = 0,
                        Data = null
                    });
                }

                // ========= SQL PARAMETERS =========
                var parameters = new[]
                {
            new SqlParameter("@Name", Name ?? (object)DBNull.Value),
            new SqlParameter("@Role", Role ?? (object)DBNull.Value),
            new SqlParameter("@PhoneNumber", PhoneNumber ?? (object)DBNull.Value),
            new SqlParameter("@Email", Email ?? (object)DBNull.Value),
            new SqlParameter("@Address", Address ?? (object)DBNull.Value),
            new SqlParameter("@CreatedBy", CreatedBy ?? (object)DBNull.Value)
        };

                string connectionString = _context.Database.GetDbConnection().ConnectionString;
                var messages = new List<string>();
                var employees = new List<Employee>();

                // ========= EXECUTE 1 LẦN DUY NHẤT =========
                using (var connection = new SqlConnection(connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("Employee_Create", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        // Capture PRINT / RAISERROR messages
                        connection.InfoMessage += (sender, e) => messages.Add(e.Message);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                employees.Add(new Employee
                                {
                                    Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                    Name = reader["Name"]?.ToString(),
                                    Role = reader["Role"]?.ToString(),
                                    PhoneNumber = reader["PhoneNumber"]?.ToString(),
                                    Email = reader["Email"]?.ToString(),
                                    Address = reader["Address"]?.ToString(),
                                    CreatedBy = reader["CreatedBy"]?.ToString(),
                                    CreatedDate = reader["CreatedDate"] as DateTime?,
                                    LastModifiedBy = reader["LastModifiedBy"]?.ToString(),
                                    LastModifiedDate = reader["LastModifiedDate"] as DateTime?,
                                    IsDeleted = reader["IsDeleted"] as bool?
                                });
                            }
                        }
                    }
                }

                // ========= LOGGING =========
                if (messages.Any())
                {
                    _logger.LogInformation("SQL Messages: {SqlMessages}", string.Join("; ", messages));
                }

                _logger.LogInformation("[{HttpMethod}] (Success) {{Name: {Name}, CreatedBy: {CreatedBy}}} SQL: {SqlMessages}",
                    httpMethod, Name, CreatedBy, string.Join("; ", messages));

                return Ok(new ResultT<List<Employee>>
                {
                    IsSuccess = true,
                    ErrorMessage = null,
                    Count = employees.Count,
                    Data = employees
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{HttpMethod}] (Exception: {Message}) {{Name: {Name}, CreatedBy: {CreatedBy}}}",
                    httpMethod, ex.Message, Name, CreatedBy);

                return StatusCode(500, new ResultT<List<Employee>>
                {
                    IsSuccess = false,
                    ErrorMessage = "An error occurred while creating the Employee.",
                    Count = 0,
                    Data = null
                });
            }
        }

        /*
                [HttpGet]
                public async Task<ActionResult<ResultT<List<Employee>>>> GetEmployeeById(
                    int? Id,
                    string? Name,
                    string? Role,
                    string? PhoneNumber,
                    string? Email,
                    string? Address,
                    int? CreatedBy,
                    DateTime? CreatedDateStart,
                    DateTime? CreatedDateEnd,
                    int? LastModifiedBy,
                    DateTime? LastModifiedDateStart,
                    DateTime? LastModifiedDateEnd)
                {
                    string httpMethod = HttpContext.Request.Method;
                    try
                    {
                        var parameters = new[]
                        {
                            new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                            new SqlParameter("@Name", Name ?? (object)DBNull.Value),
                            new SqlParameter("@Role", (object)Role ?? DBNull.Value),
                            new SqlParameter("@PhoneNumber", (object)PhoneNumber ?? DBNull.Value),
                            new SqlParameter("@Email", Email ?? (object)DBNull.Value),
                            new SqlParameter("@Address", (object)Address ?? DBNull.Value),
                            new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                            new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                            new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                            new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                            new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                            new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                        };

                        // Capture SQL messages
                        var messages = new List<string>();
                        string connectionString = _context.Database.GetDbConnection().ConnectionString;
                        using (var connection = new SqlConnection(connectionString))
                        {
                            await connection.OpenAsync();
                            var command = new SqlCommand("Employee_Read", connection)
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

                        var result = await _context.Employee.FromSqlRaw(
                            $"EXEC Employee_Read @Id, @Name, @Role, @PhoneNumber, @Email, @Address, @CreatedBy, @CreatedDateStart, @CreatedDateEnd, @LastModifiedBy, @LastModifiedDateStart, @LastModifiedDateEnd",
                            parameters).ToListAsync();

                        // Log SQL messages
                        if (messages.Any())
                        {
                            _logger.LogInformation("SQL Messages: {SqlMessages}", string.Join("; ", messages));
                        }

                        _logger.LogInformation("Employee_Read parameters: Id={Id}, Name={Name},Role = {Role},PhoneNumber = {PhoneNumber}, Email={Email},Address= {Address} CreatedBy={CreatedBy}, CreatedDateStart={CreatedDateStart}, CreatedDateEnd={CreatedDateEnd}, LastModifiedBy={LastModifiedBy}, LastModifiedDateStart={LastModifiedDateStart}, LastModifiedDateEnd={LastModifiedDateEnd}",
                            Id, Name,Role, PhoneNumber, Email, Address, CreatedBy, CreatedDateStart, CreatedDateEnd, LastModifiedBy, LastModifiedDateStart, LastModifiedDateEnd);

                        if (result.Any())
                        {
                            _logger.LogInformation("[{HttpMethod}] -(Success) {{Id: {Id}}}, SQL Messages: {SqlMessages}",
                                httpMethod, Id, string.Join("; ", messages));
                            return Ok(new ResultT<List<Employee>>
                            {
                                IsSuccess = true,
                                ErrorMessage = null,
                                Count = result.Count,
                                Data = result
                            });
                        }

                        _logger.LogWarning("[{HttpMethod}] -(Not found) {{Id: {Id}}}, SQL Messages: {SqlMessages}",
                            httpMethod, Id, string.Join("; ", messages));
                        return NotFound(new ResultT<List<Employee>>
                        {
                            IsSuccess = false,
                            ErrorMessage = "Employee not found",
                            Count = 0,
                            Data = null
                        });
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "[{HttpMethod}] -(Exception: {ExceptionMessage}) {{Id: {Id}}}",
                            httpMethod, ex.Message, Id);
                        return StatusCode(500, new ResultT<List<Employee>>
                        {
                            IsSuccess = false,
                            ErrorMessage = "An error occurred while retrieving the Employee.",
                            Count = 0,
                            Data = null
                        });
                    }
                }*/
        [HttpGet]
        public async Task<ActionResult<ResultT<List<Employee>>>> GetEmployee(
            int? Id,
            string? Name,
            string? Role,
            string? PhoneNumber,
            string? Email,
            string? Address,
            string? CreatedBy,
            DateTime? CreatedDateStart,
            DateTime? CreatedDateEnd,
            string? LastModifiedBy,
            DateTime? LastModifiedDateStart,
            DateTime? LastModifiedDateEnd)

        
        /*        public int Id { get; set; }
                public string Name { get; set; }
                public string Role { get; set; }
                public string PhoneNumber { get; set; }
                public string Email { get; set; }
                public string Address { get; set; }

                public int? CreatedBy { get; set; }
                public DateTime? CreatedDate { get; set; }
                public int? LastModifiedBy { get; set; }
                public DateTime? LastModifiedDate { get; set; }
                public bool? IsDeleted { get; set; }*/
        {
            string httpMethod = HttpContext.Request.Method;
            try
            {
                var parameters = new[]
                {
                    new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                    new SqlParameter("@Name", (object)Name ?? DBNull.Value),
                    new SqlParameter("@Role", (object)Role ?? DBNull.Value),
                    new SqlParameter("@PhoneNumber", (object)PhoneNumber ?? DBNull.Value),
                    new SqlParameter("@Email", (object)Email ?? DBNull.Value),
                    new SqlParameter("@Address", (object)Address ?? DBNull.Value),
                    new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                    new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                    new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                };

                // Capture SQL messages
                var messages = new List<string>();
                string connectionString = _context.Database.GetDbConnection().ConnectionString;
                using (var connection = new SqlConnection(connectionString))
                {
                    await connection.OpenAsync();
                    var command = new SqlCommand("Employee_Read", connection)
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

                var result = await _context.Employee.FromSqlRaw(
                    $"EXEC Employee_Read @Id",
                    parameters).ToListAsync();

                // Log SQL messages
                if (messages.Any())
                {
                    _logger.LogInformation("SQL Messages: {SqlMessages}", string.Join("; ", messages));
                }

                _logger.LogInformation("Employee_Read parameters: Id={Id}",
                    Id);

                if (result.Any())
                {
                    _logger.LogInformation("[{HttpMethod}] -(Success) {{Id: {Id}}}, SQL Messages: {SqlMessages}",
                        httpMethod, Id, string.Join("; ", messages));
                    return Ok(new ResultT<List<Employee>>
                    {
                        IsSuccess = true,
                        ErrorMessage = null,
                        Count = result.Count,
                        Data = result
                    });
                }

                _logger.LogWarning("[{HttpMethod}] -(Not found) {{Id: {Id}}}, SQL Messages: {SqlMessages}",
                    httpMethod, Id, string.Join("; ", messages));
                return NotFound(new ResultT<List<Employee>>
                {
                    IsSuccess = false,
                    ErrorMessage = "Employee not found",
                    Count = 0,
                    Data = null
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{HttpMethod}] -(Exception: {ExceptionMessage}) {{Id: {Id}}}",
                    httpMethod, ex.Message, Id);
                return StatusCode(500, new ResultT<List<Employee>>
                {
                    IsSuccess = false,
                    ErrorMessage = "An error occurred while retrieving the Employee.",
                    Count = 0,
                    Data = null
                });
            }
        }
        [HttpPut("{Id}")]
        public async Task<ActionResult<ResultT<string>>> PutEmployee(
            int? Id,
            string? Name,
            string? Role,
            string? PhoneNumber,
            string? Email,
            string? Address,
            string? LastModifiedBy)
        {
            string httpMethod = HttpContext.Request.Method;
            try
            {
                if (string.IsNullOrEmpty(Name) && string.IsNullOrEmpty(Email) && string.IsNullOrEmpty(Role) && string.IsNullOrEmpty(PhoneNumber))
                {
                    _logger.LogError("[{HttpMethod}] -(Validation failed) {{Id: {Id}, Name: {Name}, Email: {Email}, Role: {Role}, PhoneNumber: {PhoneNumber}}}",
                        httpMethod, Id, Name ?? "null", Email ?? "null", Role ?? "null", PhoneNumber ?? "null");
                    return BadRequest(new ResultT<string>
                    {
                        IsSuccess = false,
                        ErrorMessage = "At least one field (Name, Email, Role, or PhoneNumber) must be provided.",
                        Count = 0,
                        Data = null
                    });
                }

                var parameters = new[]
                {
                    new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                    new SqlParameter("@Name", Name ?? (object)DBNull.Value),
                    new SqlParameter("@Role", (object)Role ?? DBNull.Value),
                    new SqlParameter("@PhoneNumber", (object)PhoneNumber ?? DBNull.Value),
                    new SqlParameter("@Email", Email ?? (object)DBNull.Value),
                    new SqlParameter("@Address", (object)Address ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                };

                // Capture SQL messages
                var messages = new List<string>();
                string connectionString = _context.Database.GetDbConnection().ConnectionString;
                using (var connection = new SqlConnection(connectionString))
                {
                    await connection.OpenAsync();
                    var command = new SqlCommand("Employee_Update", connection)
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

                // Log SQL messages
                if (messages.Any())
                {
                    _logger.LogInformation("SQL Messages: {SqlMessages}", string.Join("; ", messages));
                }

                _logger.LogInformation("[{HttpMethod}] -(Success) {{Id: {Id}, LastModifiedBy: {LastModifiedBy}}}, SQL Messages: {SqlMessages}",
                    httpMethod, Id, LastModifiedBy, string.Join("; ", messages));

                return Ok(new ResultT<string>
                {
                    IsSuccess = true,
                    ErrorMessage = null,
                    Count = 1,
                    Data = "Employee updated successfully."
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{HttpMethod}] -(Exception: {ExceptionMessage}) {{Id: {Id}, LastModifiedBy: {LastModifiedBy}}}",
                    httpMethod, ex.Message, Id, LastModifiedBy);
                return StatusCode(500, new ResultT<string>
                {
                    IsSuccess = false,
                    ErrorMessage = "An error occurred while updating the Employee.",
                    Count = 0,
                    Data = null
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<ResultT<string>>> SoftDeleteEmployee(int id, [FromQuery] string? lastModifiedBy)
        {
            string httpMethod = HttpContext.Request.Method;
            try
            {
                var parameters = new[]
                {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@LastModifiedBy", lastModifiedBy)
                };

                // Capture SQL messages
                var messages = new List<string>();
                string connectionString = _context.Database.GetDbConnection().ConnectionString;
                using (var connection = new SqlConnection(connectionString))
                {
                    await connection.OpenAsync();
                    var command = new SqlCommand("Employee_SoftDelete", connection)
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

                // Execute the stored procedure via EF Core
                await _context.Database.ExecuteSqlRawAsync($"EXEC Employee_SoftDelete @Id, @LastModifiedBy", parameters);

                // Log SQL messages
                string sqlMessages = messages.Any() ? string.Join("; ", messages) : "No messages";
                _logger.LogInformation("SQL Messages: {SqlMessages}", sqlMessages);

                _logger.LogInformation("[{HttpMethod}] -(Success) {{Id: {Id}, LastModifiedBy: {LastModifiedBy}}}, SQL Messages: {SqlMessages}",
                    httpMethod, id, lastModifiedBy, sqlMessages);

                // Use the message from the stored procedure if available
                string successMessage = messages.Any() ? messages[0] : "Employee soft deleted successfully.";
                return Ok(new ResultT<string>
                {
                    IsSuccess = true,
                    ErrorMessage = null,
                    Count = 1,
                    Data = successMessage
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{HttpMethod}] -(Exception: {ExceptionMessage}) {{Id: {Id}, LastModifiedBy: {LastModifiedBy}}}",
                    httpMethod, ex.Message, id, lastModifiedBy);
                return StatusCode(500, new ResultT<string>
                {
                    IsSuccess = false,
                    ErrorMessage = "An error occurred while soft deleting the Employee.",
                    Count = 0,
                    Data = null
                });
            }
        }
    }
}