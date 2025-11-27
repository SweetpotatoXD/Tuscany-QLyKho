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
    public class OutboundDetailController : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;
        private readonly ILogger<OutboundDetailController> _logger;

        public OutboundDetailController(GioiThieuCtyContext context, ILogger<OutboundDetailController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // 1. GET: Dùng Procedure OutboundDetail_Read
        [HttpGet]
        public async Task<ActionResult<ResultT<List<OutboundDetail>>>> Get(
            int? Id,
            int? OutboundReceiptId,
            int? ProductId,
            int? QuantityFrom,
            int? QuantityTo,
            int? UnitPriceFrom,
            int? UnitPriceTo,
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
                    new SqlParameter("@OutboundReceiptId", (object)OutboundReceiptId ?? DBNull.Value),
                    new SqlParameter("@ProductId", (object)ProductId ?? DBNull.Value),
                    new SqlParameter("@QuantityFrom", (object)QuantityFrom ?? DBNull.Value),
                    new SqlParameter("@QuantityTo", (object)QuantityTo ?? DBNull.Value),
                    new SqlParameter("@UnitPriceFrom", (object)UnitPriceFrom ?? DBNull.Value),
                    new SqlParameter("@UnitPriceTo", (object)UnitPriceTo ?? DBNull.Value),
                    new SqlParameter("@CreatedBy", (object)CreatedBy ?? DBNull.Value),
                    new SqlParameter("@CreatedDateStart", (object)CreatedDateStart ?? DBNull.Value),
                    new SqlParameter("@CreatedDateEnd", (object)CreatedDateEnd ?? DBNull.Value),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateStart", (object)LastModifiedDateStart ?? DBNull.Value),
                    new SqlParameter("@LastModifiedDateEnd", (object)LastModifiedDateEnd ?? DBNull.Value)
                };

                var result = await _context.OutboundDetail.FromSqlRaw(
                    "EXEC OutboundDetail_Read @Id, @OutboundReceiptId, @ProductId, @QuantityFrom, @QuantityTo, @UnitPriceFrom, @UnitPriceTo, @CreatedBy, @CreatedDateStart, @CreatedDateEnd, @LastModifiedBy, @LastModifiedDateStart, @LastModifiedDateEnd",
                    parameters).ToListAsync();

                return Ok(new ResultT<List<OutboundDetail>>
                {
                    IsSuccess = true,
                    Count = result.Count,
                    Data = result
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Get OutboundDetail failed");
                return StatusCode(500, new ResultT<List<OutboundDetail>> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 2. POST: Dùng EF Core thuần (Để lấy ID mới cho Detail)
        [HttpPost]
        public async Task<ActionResult<ResultT<OutboundDetail>>> Create(
            int OutboundReceiptId,
            int ProductId,
            int Quantity,
            int UnitPrice,
            string? CreatedBy)
        {
            try
            {
                var newDetail = new OutboundDetail
                {
                    OutboundReceiptId = OutboundReceiptId,
                    ProductId = ProductId,
                    Quantity = Quantity,
                    UnitPrice = UnitPrice,
                    CreatedBy = CreatedBy,
                    CreatedDate = DateTime.Now,
                    IsDeleted = false
                };

                _context.OutboundDetail.Add(newDetail);
                await _context.SaveChangesAsync();

                return Ok(new ResultT<OutboundDetail>
                {
                    IsSuccess = true,
                    Data = newDetail, // Object này đã có ID
                    ErrorMessage = "Create detail success"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<OutboundDetail> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 3. PUT: Dùng Procedure OutboundDetail_Update
        [HttpPut("{id}")]
        public async Task<ActionResult<ResultT<string>>> Update(
            int id,
            int OutboundReceiptId,
            int ProductId,
            int Quantity,
            int UnitPrice,
            string? LastModifiedBy)
        {
            try
            {
                var parameters = new[] {
                    new SqlParameter("@Id", id),
                    new SqlParameter("@OutboundReceiptId", OutboundReceiptId),
                    new SqlParameter("@ProductId", ProductId),
                    new SqlParameter("@Quantity", Quantity),
                    new SqlParameter("@UnitPrice", UnitPrice),
                    new SqlParameter("@LastModifiedBy", (object)LastModifiedBy ?? DBNull.Value)
                };

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC OutboundDetail_Update @Id, @OutboundReceiptId, @ProductId, @Quantity, @UnitPrice, @LastModifiedBy",
                    parameters);

                return Ok(new ResultT<string> { IsSuccess = true, Data = "Updated successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ResultT<string> { IsSuccess = false, ErrorMessage = ex.Message });
            }
        }

        // 4. DELETE: Dùng Procedure OutboundDetail_SoftDelete
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
                    "EXEC OutboundDetail_SoftDelete @Id, @LastModifiedBy",
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