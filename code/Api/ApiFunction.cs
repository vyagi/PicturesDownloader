using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Messaging.ServiceBus;

namespace Api;

public class ApiFunction(ILogger<ApiFunction> logger)
{
    private readonly ILogger<ApiFunction> _logger = logger;

    [Function("request")]
    public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest req)
    {
		try
		{
            var url = req.Query["url"].ToString();

            if (string.IsNullOrWhiteSpace(url))
                return new BadRequestObjectResult("Missing 'url' query parameter.");

            _logger.LogInformation("Received URL: {url}", url);

            var serviceBusConnectionString =
                Environment.GetEnvironmentVariable("SERVICE_BUS_CONNECTION_STRING") ?? throw new InvalidOperationException("SERVICE_BUS_CONNECTION_STRING is not set");

            var client = new ServiceBusClient(serviceBusConnectionString);

            var sender = client.CreateSender("requests");

            await sender.SendMessageAsync(new ServiceBusMessage(url));

            return new OkObjectResult("Request accepted.");
        }
		catch (Exception ex)
		{
            _logger.LogError(ex, "Failed to process the request");

            throw;
        }
    }
}