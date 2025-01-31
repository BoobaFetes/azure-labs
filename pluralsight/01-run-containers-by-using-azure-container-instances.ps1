## a cloud guru hands-lab : 
# Run Containers by Using Azure Container Instances

# Instructions
# 1 - Open an incognito or in-private window, and log in to the Azure portal using the username and password provided in the lab environment.
# 2 - From within the portal, initiate the Cloud Shell, and when prompted, select a Bash shell (versus PowerShell).
# 3 - When prompted, choose "Mount a Storage Account."
# 4 - Choose the lab subscription and click Apply.
# 5 - Select the storage account that's already been deployed for you. => "Select already existing storage account"
# 6 - Select the one, existing, resource group.
# 7 - Create a new fileshare and name it "fileshare" (all lower-case)
# 8 - Click Apply.
# 9 - Wait for the command prompt to appear.

######
# le script a été fait à partir de mes souvenir et n'a jamais été executé 
# donc il est probable qu'il ne fonctionne pas ou ne remplisse pas les objectifs attendus du Lab
######

# use [shift + inser] to past item in the cloud shell terminal, ctrl+C doesn't works

$lab = @{ location = "East US"; }
$random = Get-Random  -Minimum 10000 -Maximum 99999
# $random = 43413

# get ressource defined by the lab
$val = @{ }
$val.rg = @{ }; 
$val.rg.name = (az group list | convertfrom-json)[0].name
$val.acr = @{ name = "myacr$random" ; sku = "Basic" }
$val.aci = @{ name = "myaci" }
$val.image = @{ name = "hello-world"; tag = "v1.0.0" ; from = "mcr.microsoft.com/hello-world" }

$val | ConvertTo-Json -Depth 10

###  implement the lab

# create the azure container registry
# solution 1 : 
az acr create -g $val.rg.name -n $val.acr.name -l $lab.location --sku Basic --admin-enabled $true

# solution 2 : as wanted by the labs 
az acr create -g $val.rg.name -n $val.acr.name -l $lab.location --sku Basic
az acr update -n $val.acr.name --admin-enabled $true

# create the Dockerfile to build the image
Set-Location ./clouddrive/
New-Item -Path ./hello-world-image -ItemType Directory | Out-Null
Set-Content -Path ./hello-world-image/Dockerfile -Value "FROM $($val.image.from)"

# build the image (and send it to the registry)
az acr build -r $val.acr.name -t "$($val.image.name):$($val.image.tag)" ./hello-world-image

# create the azure container instance
# do it with the portal > from the resource group > add > container instance
# then set settins but the name has to be : 
write-host '$val.aci.name = ' $val.aci.name

# go in your new container instance the in the overview tab you can see "start", click on it
# go  in the containers tab and click on the container name to see the logs
# but lgs are not setup so we can't see the expected log of the execution : 

# Annex :
## remember you can : create a container group with a single image
### az container create -g $val.rg.name -n $val.aci.name --image "$($val.image.name):$($val.image.tag)" --restart-policy OnFailure