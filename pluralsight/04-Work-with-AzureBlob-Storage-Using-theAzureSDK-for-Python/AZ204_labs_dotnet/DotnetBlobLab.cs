using Azure.Storage.Blobs;

namespace AZ204_labs_dotnet
{
    internal class DotnetBlobLab
    {
        public string ConnectionString { get; set; }
        public string ContainerName { get; set; }
        public string BlobName { get; set; }

        private Action<string?> _writeLine;

        private string _blobSampleFullFileName = Path.Combine(Directory.GetCurrentDirectory(), "BlobSample.txt");

        public DotnetBlobLab(string containerName, string blobName, string connectionstring, Action<string?> writeLine)
        {
            ContainerName = containerName;
            BlobName = blobName;
            ConnectionString = connectionstring;

            _writeLine = writeLine;
        }

        public void Execute()
        {
            if (ConnectionString == null) throw new ArgumentNullException(nameof(ConnectionString));

            var blobService = new BlobServiceClient(ConnectionString);

            var containerClient = blobService.GetBlobContainerClient(ContainerName);            
            containerClient.CreateIfNotExists();

            var blobClient = containerClient.GetBlobClient(BlobName);
            if (blobClient.Exists())
            {
                blobClient.Delete();
                _writeLine($"Blob {BlobName} is deleted");
                return;
            }

            using (var fileStream = File.OpenRead(_blobSampleFullFileName))
            {
                blobClient.Upload(fileStream, overwrite: true);
                _writeLine($"Blob {BlobName} is created");
            }
        }
    }
}
