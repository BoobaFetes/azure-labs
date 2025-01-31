## a cloud guru hands-lab : 
# Stage a .NET Web App Using App Service Deployment Slots and Azure CLI

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

###  implement the lab

# create a web app, build and publish the app
dotnet new webapp -o ./webapp
dotnet build ./webapp/webapp.csproj -c release
dotnet publish ./webapp/webapp.csproj -c release -o ./dist

# create a app service plan, the web app and deploy the app
Set-Location ./webapp
az webapp up -g $val.rg.name -n $val.webapp.name -r $val.webapp.runtime -l $lab.location --plan $val.webapp.plan.name --sku $val.webapp.plan.sku
# note : 
#   1. the app service plan and  and the web app are created if they don't exist
#   2. the app is deployed from the current working directory, so set the location to the csproj directory
Set-Location ..

# create the deployment slot "staging"
az webapp deployment slot create -g $val.rg.name -n $val.webapp.name --slot $val.webapp.deploySlot

# get the web app : not required but can help to check the webapp service 
# az webapp show -g $val.rg.name -n $val.webapp.name

# update the app
code ./webapp/Pages/Index.cshtml

# build, publish the updated app then zip the new version
dotnet build ./webapp/webapp.csproj -c release
dotnet publish ./webapp/webapp.csproj -c release -o ./dist-updated
Compress-Archive -Path ./dist-updated/* -DestinationPath ./dist-updated.zip -update
## ATTENTION : la commande compress-archive ajoute le dossier root si "-path ./dist-updated" est utilisé 
## alors que justement on n'en veux pas pour une publication de l'app (ms deploy)

# deploy the updated app (zip) to the slot "staging"
az webapp deploy -g $val.rg.name -n $val.webapp.name --slot $val.webapp.deploySlot --src-path ./dist-updated.zip
# lab video version : but deprecated : az webapp deployment source config-zip -g $val.rg.name -n $val.webapp.name --slot $val.webapp.deploySlot --src ./dist-updated.zip

# swap the staging slot to production
az webapp deployment slot swap -g $val.rg.name -n $val.webapp.name --slot $val.webapp.deploySlot

## Annexe 
# delete a deployment slot :
az webapp deployment slot delete -g $val.rg.name -n $val.webapp.name --slot $val.webapp.deploySlot
