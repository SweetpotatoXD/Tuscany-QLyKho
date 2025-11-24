using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using GioiThieuCty.Data;
using GioiThieuCty.Models.DB;
using GioiThieuCty.Models.objResponse;

namespace GioiThieuCty.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class getAdmin : ControllerBase
    {
        private readonly GioiThieuCtyContext _context;
        private readonly ILogger<getAdmin> _logger;

        public getAdmin(GioiThieuCtyContext context, ILogger<getAdmin> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<ResultT<string>>> GetUsernameById()
        {
            string httpMethod = HttpContext.Request.Method;
            var result = await _context.Admin
                .FromSqlRaw("EXEC User_GetUsername").ToListAsync();

            if (result == null)
            {
                _logger.LogWarning("Api get id null",
                    httpMethod);
                return NotFound(new ResultT<List<Admin>>
                {
                    IsSuccess = false,
                    ErrorMessage = "No data",
                    Count = 0,
                    Data = null
                });
            }


            return Ok(new ResultT<List<Admin>>
            {
                IsSuccess = true,
                ErrorMessage = null,
                Count = 1,
                Data = result
            });
        }
    }
}