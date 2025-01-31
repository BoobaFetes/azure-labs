// See https://aka.ms/new-console-template for more information
using AZ204_labs_dotnet;

Console.WriteLine("Hello, World!");

var blobLab = new DotnetBlobLab(
    containerName: "containerforlab",
    blobName: "blobforlab",
    connectionstring: "[PASTE YOUR CONNECTION STRING WRAPPED IN DOUBLE-QUOTES]",
    writeLine: Console.WriteLine
    );

blobLab.Execute();