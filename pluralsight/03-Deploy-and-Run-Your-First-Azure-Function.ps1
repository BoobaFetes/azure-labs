a cloud guru 

# use [shift + inser] to past item in the cloud shell terminal, ctrl+C doesn't works
## astuce pour forcer le cloud shell à passer en mode powershell classique et eviter de perdre les variables d'environnement
code .

$lab = @{ location = "South Central US"; }
$random = Get-Random  -Minimum 10000 -Maximum 99999
# $random = 32990

# get ressource defined by the lab
$val = @{ }
$val.rg = @{ }; 
$val.rg.name = (az group list | convertfrom-json)[0].name
$val.webapp = @{ name = "myWebApp$($random)"; runtime = "dotnet:7"; deploySlot = "staging"; plan = @{ name = "myAppServicePlan$($random)"; sku = "s1" } }

$val | ConvertTo-Json -Depth 10

# le lab semble ne pas exister .........