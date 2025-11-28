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
    public class SupplierController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;

        public SupplierController(GioiThieuCtyContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<ResultT<List<Supplier>>>> Get(
            int? Id, string? Name, string? Email, string? PhoneNumber, string? Address, string? Description,
            string? CreatedBy, DateTime? CreatedDateStart, DateTime? CreatedDateEnd,
            string? LastModifiedBy, DateTime? LastModifiedDateStart, DateTime? LastModifiedDateEnd)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                    new SqlParameter("@Name", (object)Name ?? DBNull.Value),
                    new SqlParameter("@Email", (object)Email ?? DBNull.Value),
                    new SqlParameter("@PhoneNumber", (object)PhoneNumber ?? DBNull.Value),
                    new SqlParameter("@Address", (object)Address ?? DBNull.Value),
                    new SqlParameter("@Description", (object)Description ?? DBNull.Value),
                    new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                    new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                    new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                };

                var result = await _context.Supplier.FromSqlRaw("EXEC Supplier_Read @Id, @Name, @Email, @PhoneNumber, @Address, @Description, @CreatedBy, @CreatedDateStart, @CreatedDateEnd, @LastModifiedBy, @LastModifiedDateStart, @LastModifiedDateEnd", parameters).ToListAsync();
                return Ok(new ResultT<List<Supplier>> { IsSuccess = true, Data = result, Count = result.Count });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<List<Supplier>> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<ResultT<Supplier>>> Create(string Name, string? Email, string? PhoneNumber, string? Address, string? Description, string? CreatedBy)
        {
            try
            {
                var newSupplier = new Supplier
                {
                    Name = Name,
                    Email = Email,
                    PhoneNumber = PhoneNumber,
                    Address = Address,
                    Description = Description,
                    CreatedBy = CreatedBy,
                    CreatedDate = DateTime.Now,
                    IsDeleted = false
                };

                _context.Supplier.Add(newSupplier);
                await _context.SaveChangesAsync();
                return Ok(new ResultT<Supplier> { IsSuccess = true, Data = newSupplier, ErrorMessage = "Create success" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<Supplier> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ResultT<string>>> Update(int id, string Name, string? Email, string? PhoneNumber, string? Address, string? Description, string? LastModifiedBy)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@Name", Name),
                    new SqlParameter("@Email", (object)Email ?? DBNull.Value),
                    new SqlParameter("@PhoneNumber", (object)PhoneNumber ?? DBNull.Value),
                    new SqlParameter("@Address", (object)Address ?? DBNull.Value),
                    new SqlParameter("@Description", (object)Description ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value)
                };
                await _context.Database.ExecuteSqlRawAsync("EXEC Supplier_Update @Id, @Name, @Email, @PhoneNumber, @Address, @Description, @LastModifiedBy", parameters);
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
                await _context.Database.ExecuteSqlRawAsync("EXEC Supplier_SoftDelete @Id, @LastModifiedBy", parameters);
                return Ok(new ResultT<string> { IsSuccess = true, Data = "Soft deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }
    }
}