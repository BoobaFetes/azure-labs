######
# le script a été fait à partir de mes souvenir et n'a jamais été executé 
# donc il est probable qu'il ne fonctionne pas ou ne remplisse pas les objectifs attendus du Lab
######

# use [shift + inser] to past item in the cloud shell terminal, ctrl+C doesn't works

$lab = @{ location = "South Central US"; }
$random = Get-Random  -Minimum 10000 -Maximum 99999
# $random = 32990

# get ressource defined by the lab
$val = @{ }
$val.rg = @{ }; 
$val.rg.name = (az group list | convertfrom-json)[0].name
$val.acr = @{ name = "my-acr$random" ; sku = "Basic" }
$val.aci = @{ name = "my-aci" }
$val.image = @{ name = "hello-world"; tag = "v1.0.0" ; from = "mcr.microsoft.com/hello-world" }
$val | ConvertTo-Json -Depth 10

###  implement the lab

# create the azure container registry
az acr create -g $val.rg.name -n $val.acr.name -l $lab.location --sku Basic --admin-enabled $true
az acr update -n $val.acr.name --admin-enabled $true

# create the Dockerfile to build the image
Set-Content -Path ./sources/Dockerfile -Value "FROM $($vl.image.from)"

# build the image (and send it to the registry)
az acr buid -r $val.acr.name -t $val.image.name:$val.image.tag ./sources/

# create the azure container instance
# do it with the portal > from the resource group > add > container instance
# then set settins but the name has to be : 
write-host '$val.aci.name = ' $val.aci.name

# create a container group with a single image
az container create -g $val.rg.name -n $val.aci.name --image "my-scope/$($val.image.name):$($val.image.tag)" --restart-policy OnFailure