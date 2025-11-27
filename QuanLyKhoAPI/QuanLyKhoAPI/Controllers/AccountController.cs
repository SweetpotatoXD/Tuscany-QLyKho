using GioiThieuCty.Data;
using GioiThieuCty.Models.DB;
using GioiThieuCty.Models.objResponse;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace GioiThieuCty.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;
        private readonly ILogger<AccountController> _logger;

        public AccountController(GioiThieuCtyContext context, ILogger<AccountController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<ResultT<List<Account>>>> Get(
            int? Id, int? EmployeeId, string? Username, bool? IsAdmin, string? CreatedBy,
            DateTime? CreatedDateStart, DateTime? CreatedDateEnd,
            string? LastModifiedBy, DateTime? LastModifiedDateStart, DateTime? LastModifiedDateEnd)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                    new SqlParameter("@EmployeeId", (object)EmployeeId ?? DBNull.Value),
                    new SqlParameter("@Username", (object)Username ?? DBNull.Value),
                    new SqlParameter("@IsAdmin", (object)IsAdmin ?? DBNull.Value),
                    new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                    new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                    new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                };

                var result = await _context.Account.FromSqlRaw("EXEC Account_Read @Id, @EmployeeId, @Username, @IsAdmin, @CreatedBy, @CreatedDateStart, @CreatedDateEnd, @LastModifiedBy, @LastModifiedDateStart, @LastModifiedDateEnd", parameters).ToListAsync();
                return Ok(new ResultT<List<Account>> { IsSuccess = true, Data = result, Count = result.Count });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<List<Account>> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<ResultT<Account>>> Create(int EmployeeId, string Username, string PasswordHash, bool IsAdmin, string? CreatedBy)
        {
            try
            {
                // Dùng EF Core Add để lấy ID tự động
                var newAccount = new Account
                {
                    EmployeeId = EmployeeId,
                    Username = Username,
                    PasswordHash = PasswordHash,
                    IsAdmin = IsAdmin,
                    CreatedBy = CreatedBy,
                    CreatedDate = DateTime.Now,
                    IsDeleted = false
                };

                _context.Account.Add(newAccount);
                await _context.SaveChangesAsync();

                return Ok(new ResultT<Account> { IsSuccess = true, Data = newAccount, ErrorMessage = "Create success" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<Account> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ResultT<string>>> Update(int id, int EmployeeId, string Username, string PasswordHash, bool IsAdmin, string? LastModifiedBy)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@EmployeeId", EmployeeId),
                    new SqlParameter("@Username", Username),
                    new SqlParameter("@PasswordHash", PasswordHash),
                    new SqlParameter("@IsAdmin", IsAdmin),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value)
                };
                await _context.Database.ExecuteSqlRawAsync("EXEC Account_Update @Id, @EmployeeId, @Username, @PasswordHash, @IsAdmin, @LastModifiedBy", parameters);
                return Ok(new ResultT<string> { IsSuccess = true, Data = "Updated successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<ResultT<string>>> Delete(int id, [FromQuery] string? lastModifiedBy)
        {
            try
            {
                var parameters = new[] { new SqlParameter("@Id", id), new SqlParameter("@LastModifiedBy", (object)lastModifiedBy ?? DBNull.Value) };
                await _context.Database.ExecuteSqlRawAsync("EXEC Account_SoftDelete @Id, @LastModifiedBy", parameters);
                return Ok(new ResultT<string> { IsSuccess = true, Data = "Soft deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }
    }
}