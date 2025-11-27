using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using GioiThieuCty.Models.DB;

namespace GioiThieuCty.Data
{
    public class GioiThieuCtyContext : DbContext
    {
        public GioiThieuCtyContext(DbContextOptions<GioiThieuCtyContext> options)
            : base(options)
        {
        }
        public DbSet<GioiThieuCty.Models.DB.Admin> Admin { get; set; }
        public DbSet<GioiThieuCty.Models.DB.AuditLog> AuditLog { get; set; }
        public DbSet<GioiThieuCty.Models.DB.Account> Account { get; set; }
        public DbSet<GioiThieuCty.Models.DB.Customer> Customer { get; set; }
        public DbSet<GioiThieuCty.Models.DB.Employee> Employee { get; set; }
        public DbSet<GioiThieuCty.Models.DB.InboundDetail> InboundDetail { get; set; }
        public DbSet<GioiThieuCty.Models.DB.InboundReceipt> InboundReceipt { get; set; }
        public DbSet<GioiThieuCty.Models.DB.OutboundDetail> OutboundDetail { get; set; }
        public DbSet<GioiThieuCty.Models.DB.OutboundReceipt> OutboundReceipt { get; set; }
        public DbSet<GioiThieuCty.Models.DB.Product> Product { get; set; }
        public DbSet<GioiThieuCty.Models.DB.Supplier> Supplier { get; set; }
    }
}