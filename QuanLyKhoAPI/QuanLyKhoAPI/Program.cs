using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Logging;
using GioiThieuCty.Data;
using Serilog;
using Serilog.Events;
using Serilog.Sinks.File; // Add this using directive
using GioiThieuCty; // Add this namespace for SwaggerDropdownOperationFilter

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<GioiThieuCtyContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("GioiThieuCtyContext") ?? throw new InvalidOperationException("Connection string 'GioiThieuCtyContext' not found.")));

// Configure logging
builder.Logging.ClearProviders(); // Disable all default logging providers
var logger = new LoggerConfiguration()
    .MinimumLevel.Information() // Set global minimum level
    .MinimumLevel.Override("Microsoft", Serilog.Events.LogEventLevel.Fatal) // Suppress Microsoft logs
    .MinimumLevel.Override("System", Serilog.Events.LogEventLevel.Fatal) // Suppress System logs
    .MinimumLevel.Override("GioiThieuCty.Controllers.UserController", Serilog.Events.LogEventLevel.Information) // Allow UserController logs
    .WriteTo.File("logs/log.txt",
        rollingInterval: Serilog.RollingInterval.Day,
        outputTemplate: "[{Timestamp:dd/M/yyyy-HH:mm:ss-zz:HH:mm.fff}] [\"{Message}\"]{NewLine}", // Match your desired format
        fileSizeLimitBytes: null,
        retainedFileCountLimit: null,
        shared: true)
    .CreateLogger();

builder.Logging.AddSerilog(logger, dispose: true);

// Set minimum log level
builder.Logging.SetMinimumLevel(LogLevel.Information);

// Add controllers and Swagger
builder.Services.AddControllers();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "WebAPICallSP", Version = "v1" });
});

var app = builder.Build();

// Configure middleware
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "WebAPICallSP v1");
    });
}
app.UseStaticFiles();
app.UseHttpsRedirection();
// app.UseRouting(); // Optional in .NET 9 with minimal APIs; included for clarity but can be removed
app.UseAuthorization();
app.MapControllers(); // Replace UseEndpoints with MapControllers for simplicity

app.Run();