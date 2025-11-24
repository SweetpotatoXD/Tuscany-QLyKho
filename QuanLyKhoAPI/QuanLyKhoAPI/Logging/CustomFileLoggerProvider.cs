using Microsoft.Extensions.Logging;
using System;

namespace GioiThieuCty.Logging
{
    public class CustomFileLoggerProvider : ILoggerProvider
    {
        private readonly string _filePath;

        public CustomFileLoggerProvider(string filePath)
        {
            _filePath = filePath;
        }

        public ILogger CreateLogger(string categoryName)
        {
            return new CustomFileLogger(categoryName, _filePath);
        }

        public void Dispose() { }
    }
}