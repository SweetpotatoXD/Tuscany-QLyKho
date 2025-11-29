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
    public class OutboundReceiptController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;
        private readonly ILogger<OutboundReceiptController> _logger;

        public OutboundReceiptController(GioiThieuCtyContext context, ILogger<OutboundReceiptController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // 1. GET: Dùng Procedure OutboundReceipt_Read
        [HttpGet]
        public async Task<ActionResult<ResultT<List<OutboundReceipt>>>> Get(
            int? Id,
            DateTime? ReceiptDateStart,
            DateTime? ReceiptDateEnd,
            int? EmployeeId,
            int? CustomerId,
            string? Note,
            string? CreatedBy,
            DateTime? CreatedDateStart,
            DateTime? CreatedDateEnd,
            string? LastModifiedBy,
            DateTime? LastModifiedDateStart,
            DateTime? LastModifiedDateEnd)
        {
            try
            {
                var parameters = new[]
                {
                    new SqlParameter("@Id", (object)Id ?? DBNull.Value),
                    new SqlParameter("@ReceiptDateStart", (object)ReceiptDateStart ?? DBNull.Value),
                    new SqlParameter("@ReceiptDateEnd", (object)ReceiptDateEnd ?? DBNull.Value),
                    new SqlParameter("@EmployeeId", (object)EmployeeId ?? DBNull.Value),
                    new SqlParameter("@CustomerId", (object)CustomerId ?? DBNull.Value),
                    new SqlParameter("@Note", (object)Note ?? DBNull.Value),
                    new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                    new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                    new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                };

                // Gọi SP Read
                var result = await _context.OutboundReceipt.FromSqlRaw(
                    "EXEC OutboundReceipt_Read @Id, @ReceiptDateStart, @ReceiptDateEnd, @EmployeeId, @CustomerId, @Note, @CreatedBy, @CreatedDateStart, @CreatedDateEnd, @LastModifiedBy, @LastModifiedDateStart, @LastModifiedDateEnd",
                    parameters).ToListAsync();

                return Ok(new ResultT<List<OutboundReceipt>>
                {
                    IsSuccess = true,
                    Count = result.Count,
                    Data = result
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Get OutboundReceipt failed");
                return StatusCode(500, new ResultT<List<OutboundReceipt>> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 2. POST: Dùng EF Core thuần để lấy ID ngay lập tức
        [HttpPost]
        public async Task<ActionResult<ResultT<OutboundReceipt>>> Create(
            DateTime? ReceiptDate,
            int? EmployeeId,
            int? CustomerId,
<<<<<<< HEAD
=======
            int? TotalPrice,
            string? Status,
>>>>>>> CALL-API
            string? Note,
            string? CreatedBy)
        {
            try
            {
                // Tạo Object Entity
                var newReceipt = new OutboundReceipt
                {
                    ReceiptDate = ReceiptDate ?? DateTime.Now,
                    EmployeeId = EmployeeId,
                    CustomerId = CustomerId,
<<<<<<< HEAD
=======
                    TotalPrice = TotalPrice,
                    Status = Status,
>>>>>>> CALL-API
                    Note = Note,
                    CreatedBy = CreatedBy,
                    CreatedDate = DateTime.Now,
                    IsDeleted = false
                };

                // Dùng EF Core Add
                _context.OutboundReceipt.Add(newReceipt);

                // SaveChanges sẽ tự động điền ID vào newReceipt.Id
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created OutboundReceipt with ID: {Id}", newReceipt.Id);

                return Ok(new ResultT<OutboundReceipt>
                {
                    IsSuccess = true,
                    Count = 1,
                    Data = newReceipt, // Trả về object có chứa ID
                    ErrorMessage = "Create success"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Create OutboundReceipt failed");
                return StatusCode(500, new ResultT<OutboundReceipt> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 3. PUT: Dùng Procedure OutboundReceipt_Update
        [HttpPut("{id}")]
        public async Task<ActionResult<ResultT<string>>> Update(
            int id,
            DateTime? ReceiptDate,
            int? EmployeeId,
            int? CustomerId,
<<<<<<< HEAD
=======
            int? TotalPrice,
            string? Status,
>>>>>>> CALL-API
            string? Note,
            string? LastModifiedBy)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@ReceiptDate", (object)ReceiptDate ?? DBNull.Value),
                    new SqlParameter("@EmployeeId", (object)EmployeeId ?? DBNull.Value),
                    new SqlParameter("@CustomerId", (object)CustomerId ?? DBNull.Value),
<<<<<<< HEAD
=======
                    new SqlParameter("@TotalPrice", (object)TotalPrice ?? DBNull.Value),
                    new SqlParameter("@Status", (object)Status ?? DBNull.Value),
>>>>>>> CALL-API
                    new SqlParameter("@Note", (object)Note ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value)
                };

                await _context.Database.ExecuteSqlRawAsync(
<<<<<<< HEAD
                    "EXEC OutboundReceipt_Update @Id, @ReceiptDate, @EmployeeId, @CustomerId, @Note, @LastModifiedBy",
=======
                    "EXEC OutboundReceipt_Update @Id, @ReceiptDate, @EmployeeId, @CustomerId, @TotalPrice, @Status, @Note, @LastModifiedBy",
>>>>>>> CALL-API
                    parameters);

                return Ok(new ResultT<string> { IsSuccess = true, Data = "Updated successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 4. DELETE: Dùng Procedure OutboundReceipt_SoftDelete
        [HttpDelete("{id}")]
        public async Task<ActionResult<ResultT<string>>> Delete(int id, [FromQuery] string? lastModifiedBy)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@LastModifiedBy", (object)lastModifiedBy ?? DBNull.Value)
                };

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC OutboundReceipt_SoftDelete @Id, @LastModifiedBy",
                    parameters);

                return Ok(new ResultT<string> { IsSuccess = true, Data = "Soft deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }
    }
}