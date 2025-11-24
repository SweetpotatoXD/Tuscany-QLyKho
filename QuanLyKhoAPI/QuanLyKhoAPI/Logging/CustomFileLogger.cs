using Microsoft.Extensions.Logging;
using System;
using System.IO;

namespace GioiThieuCty.Logging
{
    public class CustomFileLogger : ILogger
    {
        private readonly string _categoryName;
        private readonly string _filePath;

        public CustomFileLogger(string categoryName, string filePath)
        {
            _categoryName = categoryName;
            _filePath = filePath;
        }

        public IDisposable BeginScope<TState>(TState state) => null;

        public bool IsEnabled(LogLevel logLevel) => true;

        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            if (!IsEnabled(logLevel))
                return;

            var message = formatter(state, exception);
            var timestamp = DateTimeOffset.Now.ToString("dd/M/yyyy-HH:mm:ss-zz:HH:mm.fff");
            var logLine = $"[{timestamp}] {message}";

            // Ensure the directory exists
            Directory.CreateDirectory(Path.GetDirectoryName(_filePath));
            // Write to file (thread-safe)
            lock (this)
            {
                File.AppendAllText(_filePath, logLine + Environment.NewLine);
            }
        }
    }
}