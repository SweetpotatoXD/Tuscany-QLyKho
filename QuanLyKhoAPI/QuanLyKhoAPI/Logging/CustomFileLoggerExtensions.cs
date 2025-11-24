using Microsoft.Extensions.Logging;
using System;

namespace GioiThieuCty.Logging
{
    public static class CustomFileLoggerExtensions
    {
        public static ILoggingBuilder AddCustomFileLogger(this ILoggingBuilder builder, string filePath)
        {
            if (string.IsNullOrEmpty(filePath))
                throw new ArgumentNullException(nameof(filePath));

            builder.AddProvider(new CustomFileLoggerProvider(filePath));
            return builder;
        }
    }
}