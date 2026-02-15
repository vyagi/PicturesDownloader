using Azure.Messaging.ServiceBus;
using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Downloader;

public class DownloaderFunction(ILogger<DownloaderFunction> logger)
{
    private static readonly HttpClient _httpClient = new();

    private readonly ILogger<DownloaderFunction> _logger = logger;

    [Function(nameof(DownloaderFunction))]
    public async Task Run(
        [ServiceBusTrigger("requests", Connection = "ServiceBus")]
        ServiceBusReceivedMessage message,
        ServiceBusMessageActions messageActions)
    {
        var imageUrl = message.Body.ToString();

        _logger.LogInformation("Processing image URL: {url}", imageUrl);

        try
        {
            var imageBytes = await _httpClient.GetByteArrayAsync(imageUrl);

            var originalName = Path.GetFileName(new Uri(imageUrl).AbsolutePath);
            var timestamp = DateTime.UtcNow.ToString("yyyyMMddHHmmssfff");
            var blobName = $"{timestamp}_{originalName}";

            var storageConnectionString =
                Environment.GetEnvironmentVariable("STORAGE_ACCOUNT_CONNECTION_STRING") ?? throw new InvalidOperationException("STORAGE_ACCOUNT_CONNECTION_STRING is not set");

            var blobServiceClient = new BlobServiceClient(storageConnectionString);

            var containerClient = blobServiceClient.GetBlobContainerClient("pictures");
            var blobClient = containerClient.GetBlobClient(blobName);

            await blobClient.UploadAsync(new MemoryStream(imageBytes));

            _logger.LogInformation("Image saved as blob: {blobName}", blobName);

            await messageActions.CompleteMessageAsync(message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process the message");

            throw;
        }
    }
}