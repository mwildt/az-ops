#!/bin/bash

dir=$1
resource_group_prefix="mw"
resource_group_name="$resource_group_prefix-$dir"

az group show --name mw-gitea > /dev/null

ressourceGroupRC=$?
if [ $ressourceGroupRC -ne 0 ]; then
    echo "create resource group with name $resource_group_name"
    az deployment sub create  \
        --location germanywestcentral \
        --template-file resource-group-template.json \
        --parameters @resource-group-parameters.json \
        --parameters rgName=$resource_group_name
fi

echo "reading registry credentials"
registryCredentials=$(az acr credential show -n tdliwreg --query passwords[0].value)
# es müssen die ""-Quotes entfernt werden 

registryCredentialRC=$?
if [ $ressourceGroupRC -ne 0 ]; then
    echo "beim lesen der Registry-Credentials ist ein Fehler aufgetreten"
    exit $ressourceGroupRC
fi
registryCredentials=${registryCredentials:1:-1}

echo "create deployment $resource_group_name / $dir"
az deployment group create -g $resource_group_name \
    --template-file $dir/template.json \
    --parameters @$dir/paramerters.json \
    --parameters rgName=$resource_group_name \
    --parameters imagePassword=$registryCredentials