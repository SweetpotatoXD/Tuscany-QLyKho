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
    public class ProductController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;

        public ProductController(GioiThieuCtyContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<ResultT<List<Product>>>> Get(
            int? Id, int? SupplierId, string? Name, string? Unit, string? CreatedBy,
            DateTime? CreatedDateStart, DateTime? CreatedDateEnd,
            string? LastModifiedBy, DateTime? LastModifiedDateStart, DateTime? LastModifiedDateEnd)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                    new SqlParameter("@SupplierId", (object)SupplierId ?? DBNull.Value),
                    new SqlParameter("@Name", (object)Name ?? DBNull.Value),
                    new SqlParameter("@Unit", (object)Unit ?? DBNull.Value),
                    new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                    new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                    new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                };

                var result = await _context.Product.FromSqlRaw("EXEC Product_Read @Id, @SupplierId, @Name, @Unit, @CreatedBy, @CreatedDateStart, @CreatedDateEnd, @LastModifiedBy, @LastModifiedDateStart, @LastModifiedDateEnd", parameters).ToListAsync();
                return Ok(new ResultT<List<Product>> { IsSuccess = true, Data = result, Count = result.Count });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<List<Product>> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<ResultT<Product>>> Create(int SupplierId, string Name, int Quantity, string Unit, string? CreatedBy)
        {
            try
            {
                var newProduct = new Product
                {
                    SupplierId = SupplierId,
                    Name = Name,
                    Quantity = Quantity,
                    Unit = Unit,
                    CreatedBy = CreatedBy,
                    CreatedDate = DateTime.Now,
                    IsDeleted = false
                };

                _context.Product.Add(newProduct);
                await _context.SaveChangesAsync();
                return Ok(new ResultT<Product> { IsSuccess = true, Data = newProduct, ErrorMessage = "Create success" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<Product> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ResultT<string>>> Update(int id, int SupplierId, string Name, int Quantity, string Unit, string? LastModifiedBy)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@SupplierId", SupplierId),
                    new SqlParameter("@Name", Name),
                    new SqlParameter("@Quantity", Quantity),
                    new SqlParameter("@Unit", Unit),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value)
                };
                await _context.Database.ExecuteSqlRawAsync("EXEC Product_Update @Id, @SupplierId, @Name, @Quantity, @Unit, @LastModifiedBy", parameters);
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
                await _context.Database.ExecuteSqlRawAsync("EXEC Product_SoftDelete @Id, @LastModifiedBy", parameters);
                return Ok(new ResultT<string> { IsSuccess = true, Data = "Soft deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }
    }
}