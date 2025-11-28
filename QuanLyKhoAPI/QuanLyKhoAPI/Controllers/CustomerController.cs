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
    public class CustomerController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;

        public CustomerController(GioiThieuCtyContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<ResultT<List<Customer>>>> Get(
            int? Id, string? Name, string? CustomerType, string? PhoneNumber, string? Email, string? Address,
            int? DebtFrom, int? DebtTo, string? CreatedBy, DateTime? CreatedDateStart, DateTime? CreatedDateEnd,
            string? LastModifiedBy, DateTime? LastModifiedDateStart, DateTime? LastModifiedDateEnd)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                    new SqlParameter("@Name", (object)Name ?? DBNull.Value),
                    new SqlParameter("@CustomerType", (object)CustomerType ?? DBNull.Value),
                    new SqlParameter("@PhoneNumber", (object)PhoneNumber ?? DBNull.Value),
                    new SqlParameter("@Email", (object)Email ?? DBNull.Value),
                    new SqlParameter("@Address", (object)Address ?? DBNull.Value),
                    new SqlParameter("@DebtFrom", (object)DebtFrom ?? DBNull.Value),
                    new SqlParameter("@DebtTo", (object)DebtTo ?? DBNull.Value),
                    new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                    new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                    new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                };

                var result = await _context.Customer.FromSqlRaw("EXEC Customer_Read @Id, @Name, @CustomerType, @PhoneNumber, @Email, @Address, @DebtFrom, @DebtTo, @CreatedBy, @CreatedDateStart, @CreatedDateEnd, @LastModifiedBy, @LastModifiedDateStart, @LastModifiedDateEnd", parameters).ToListAsync();
                return Ok(new ResultT<List<Customer>> { IsSuccess = true, Data = result, Count = result.Count });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<List<Customer>> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<ResultT<Customer>>> Create(string Name, string CustomerType, string PhoneNumber, string Email, string Address, string? CreatedBy)
        {
            try
            {
                var newCustomer = new Customer
                {
                    Name = Name,
                    CustomerType = CustomerType,
                    PhoneNumber = PhoneNumber,
                    Email = Email,
                    Address = Address,
                    Debt = 0, // Mặc định Debt là 0
                    CreatedBy = CreatedBy,
                    CreatedDate = DateTime.Now,
                    IsDeleted = false
                };

                _context.Customer.Add(newCustomer);
                await _context.SaveChangesAsync();
                return Ok(new ResultT<Customer> { IsSuccess = true, Data = newCustomer, ErrorMessage = "Create success" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<Customer> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ResultT<string>>> Update(int id, string Name, string CustomerType, string PhoneNumber, string Email, string Address, int Debt, string? LastModifiedBy)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@Name", Name),
                    new SqlParameter("@CustomerType", CustomerType),
                    new SqlParameter("@PhoneNumber", PhoneNumber),
                    new SqlParameter("@Email", Email),
                    new SqlParameter("@Address", Address),
                    new SqlParameter("@Debt", Debt),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value)
                };
                await _context.Database.ExecuteSqlRawAsync("EXEC Customer_Update @Id, @Name, @CustomerType, @PhoneNumber, @Email, @Address, @Debt, @LastModifiedBy", parameters);
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
                await _context.Database.ExecuteSqlRawAsync("EXEC Customer_SoftDelete @Id, @LastModifiedBy", parameters);
                return Ok(new ResultT<string> { IsSuccess = true, Data = "Soft deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }
    }
}