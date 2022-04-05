#!/bin/bash
dir="$1-vm"

resource_group_prefix=$2
resource_group_name="$resource_group_prefix-$dir"

# gibt es die ermittelte resourcengruppe bereit?
az group show --name $resource_group_name > /dev/null

# falls nicht -> rg wird angeleget.
ressourceGroupRC=$?
if [ $ressourceGroupRC -ne 0 ]; then
    echo "create resource group with name $resource_group_name"
    az deployment sub create  \
        --location germanywestcentral \
        --template-file resource-group-template.json \
        --parameters @resource-group-parameters.json \
        --parameters rgName=$resource_group_name
fi

sshdir=./.ssh
mkdir -p $sshdir
keyname=${sshdir}/${resource_group_name}_id_rsa
# generate new ssh key

if test -f "$keyname"; then
    echo "key $keyname already exists. None will be created"
else 
    ssh-keygen -m PEM -t rsa -b 4096 -f $keyname
fi

# laden den public Key

publicKeyData=$(<${sshdir}/${resource_group_name}_id_rsa.pub)

## https://docs.microsoft.com/de-de/azure/virtual-machines/extensions/custom-script-linux

# und dann das deployment starten...
echo "create deployment $resource_group_name / $dir"
az deployment group create -g $resource_group_name \
    --template-file $dir/template.json \
    --parameters @$dir/paramerters.json \
    --parameters rgName=$resource_group_name \
    --parameters publicKeyData="$publicKeyData"