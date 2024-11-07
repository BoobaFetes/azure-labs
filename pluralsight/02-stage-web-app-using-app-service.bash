## astuce pour forcer le cloud shell à passer en mode powershell classique et eviter de perdre les variables d'environnement
code .

# Définir les variables
location="South Central US"
random=$((RANDOM % 90000 + 10000))
# random=32990

# Obtenir le nom du groupe de ressources
rg_name=$(az group list --query '[0].name' -o tsv)
webapp_name="myWebApp$random"
runtime="dotnet:7"
deploy_slot="staging"
plan_name="myAppServicePlan$random"
sku="S1"

# Afficher les valeurs des variables
echo "Resource Group: $rg_name"
echo "Web App: $webapp_name"
echo "Runtime: $runtime"
echo "Deploy Slot: $deploy_slot"
echo "App Service Plan: $plan_name"
echo "SKU: $sku"

# Créer une application web, compiler et publier l'application
dotnet new webapp -o ./webapp
dotnet build ./webapp/webapp.csproj -c release
dotnet publish ./webapp/webapp.csproj -c release -o ./dist

# Changer le répertoire actuel pour ./webapp
cd ./webapp

# Créer un App Service Plan, la Web App et déployer l'application
az webapp up --resource-group $rg_name --name $webapp_name --runtime $runtime --location "$location" --plan $plan_name --sku $sku

# Créer le slot de déploiement "staging"
az webapp deployment slot create --name $webapp_name --resource-group $rg_name --slot $deploy_slot

# Afficher les informations de la Web App
az webapp show --resource-group $rg_name --name $webapp_name

cd ..
# Mettre à jour l'application
code ./webapp/Pages/Index.cshtml

# Compiler puis publier l'application mise à jour
dotnet build ./webapp/webapp.csproj -c release
dotnet publish ./webapp/webapp.csproj -c release -o ./dist-updated

# Préparer l'archive ZIP pour le déploiement sur le slot staging
cd ./dist-updated
zip -r ../dist-updated.zip .

# Déployer l'application mise à jour sur le slot "staging"
az webapp deployment source config-zip -g $rg_name -n $webapp_name --slot $deploy_slot --src ./dist-updated.zip

# En cas d'échec de déploiement, supprimer le slot
# az webapp deployment slot delete --resource-group $rg_name --name $webapp_name --slot $deploy_slot

# Swap du slot "staging" en production
az webapp deployment slot swap --resource-group $rg_name --name $webapp_name --slot $deploy_slot
