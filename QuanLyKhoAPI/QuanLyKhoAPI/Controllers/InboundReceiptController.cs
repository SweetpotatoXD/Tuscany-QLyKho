using GioiThieuCty.Data;
using GioiThieuCty.Models.DB;
using GioiThieuCty.Models.objResponse; // Giả sử namespace chứa ResultT
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace GioiThieuCty.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class InboundReceiptController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;
        private readonly ILogger<InboundReceiptController> _logger;

        public InboundReceiptController(GioiThieuCtyContext context, ILogger<InboundReceiptController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // 1. GET: Dùng Procedure InboundReceipt_Read
        [HttpGet]
        public async Task<ActionResult<ResultT<List<InboundReceipt>>>> Get(
            int? Id,
            DateTime? ReceiptDateStart,
            DateTime? ReceiptDateEnd,
            int? EmployeeId,
            int? SupplierId,
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
                    new SqlParameter("@SupplierId", (object)SupplierId ?? DBNull.Value),
                    new SqlParameter("@Note", (object)Note ?? DBNull.Value),
                    new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                    new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                    new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                };

                var result = await _context.InboundReceipt.FromSqlRaw(
                    "EXEC InboundReceipt_Read @Id, @ReceiptDateStart, @ReceiptDateEnd, @EmployeeId, @SupplierId, @Note, @CreatedBy, @CreatedDateStart, @CreatedDateEnd, @LastModifiedBy, @LastModifiedDateStart, @LastModifiedDateEnd",
                    parameters).ToListAsync();

                return Ok(new ResultT<List<InboundReceipt>>
                {
                    IsSuccess = true,
                    Count = result.Count,
                    Data = result
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Get InboundReceipt failed");
                return StatusCode(500, new ResultT<List<InboundReceipt>> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 2. POST: Dùng EF Core thuần để lấy ID (Không dùng Procedure Create)
        [HttpPost]
        public async Task<ActionResult<ResultT<InboundReceipt>>> Create(
            DateTime? ReceiptDate,
            int? EmployeeId,
            int? SupplierId,
            int? TotalPrice,
            string? Note,
            string? CreatedBy)
        {
            try
            {
                // Tạo Object Entity
                var newReceipt = new InboundReceipt
                {
                    ReceiptDate = ReceiptDate ?? DateTime.Now,
                    EmployeeId = EmployeeId,
                    SupplierId = SupplierId,
                    TotalPrice = TotalPrice,
                    Note = Note,
                    CreatedBy = CreatedBy,
                    CreatedDate = DateTime.Now,
                    IsDeleted = false
                    // LastModified để null khi tạo mới
                };

                // Sử dụng EF Core Add
                _context.InboundReceipt.Add(newReceipt);

                // Khi SaveChanges, EF Core tự động lấy ID gán ngược lại vào newReceipt.Id
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created InboundReceipt with ID: {Id}", newReceipt.Id);

                return Ok(new ResultT<InboundReceipt>
                {
                    IsSuccess = true,
                    Count = 1,
                    // Trả về cả object, Client sẽ lấy .Id từ đây để gọi API tạo Detail
                    Data = newReceipt,
                    ErrorMessage = "Create success"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Create InboundReceipt failed");
                return StatusCode(500, new ResultT<InboundReceipt> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 3. PUT: Dùng Procedure InboundReceipt_Update
        [HttpPut("{id}")]
        public async Task<ActionResult<ResultT<string>>> Update(
            int id,
            DateTime? ReceiptDate,
            int? EmployeeId,
            int? SupplierId,
            int? TotalPrice,
            string? Note,
            string? LastModifiedBy)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@ReceiptDate", (object)ReceiptDate ?? DBNull.Value),
                    new SqlParameter("@EmployeeId", (object)EmployeeId ?? DBNull.Value),
                    new SqlParameter("@SupplierId", (object)SupplierId ?? DBNull.Value),
                    new SqlParameter("@TotalPrice", (object)TotalPrice ?? DBNull.Value),
                    new SqlParameter("@Note", (object)Note ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value)
                };

                await _context.Database.ExecuteSqlRawAsync("EXEC InboundReceipt_Update @Id, @ReceiptDate, @EmployeeId, @SupplierId, @TotalPrice, @Note, @LastModifiedBy", parameters);

                return Ok(new ResultT<string> { IsSuccess = true, Data = "Updated successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 4. DELETE: Dùng Procedure InboundReceipt_SoftDelete
        [HttpDelete("{id}")]
        public async Task<ActionResult<ResultT<string>>> Delete(int id, [FromQuery] string? lastModifiedBy)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                string deleteDetailSql = @"UPDATE InboundDetail SET IsDeleted = 1, LastModifiedBy = @LastModifiedBy, LastModifiedDate = GETDATE() WHERE InboundReceiptId = @Id AND IsDeleted = 0";

                var detailParams = new[] {
            new SqlParameter("@Id", id),
            new SqlParameter("@LastModifiedBy", (object)lastModifiedBy ?? DBNull.Value)
        };

                await _context.Database.ExecuteSqlRawAsync(deleteDetailSql, detailParams);

                var masterParams = new[] {
            new SqlParameter("@Id", id),
            new SqlParameter("@LastModifiedBy", (object)lastModifiedBy ?? DBNull.Value)
        };

                await _context.Database.ExecuteSqlRawAsync("EXEC InboundReceipt_SoftDelete @Id, @LastModifiedBy", masterParams);

                await transaction.CommitAsync();

                return Ok(new ResultT<string>
                {
                    IsSuccess = true,
                    Data = "Deleted successfully"
                });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "Delete failed");
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }
    }
}