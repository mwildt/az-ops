#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--name)
      CLUSTER_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -t|--type)
      CLUSTER_TYPE="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      echo "Unknown paramer $1"
      exit 1
      ;;
  esac
done

if [ -v CLUSTER_NAME ]; then 
   echo "Cluster Name: $CLUSTER_NAME"
else
    echo "kein Cluster-Name angegeben"
    exit 1;
fi

if [ -v CLUSTER_TYPE ]; then 
    echo "Cluster Type: $CLUSTER_TYPE"
else 
    echo "kein Cluster-Type angegeben"
    exit 1;
fi



RESOURCE_GROUP_NAME=$CLUSTER_NAME-$CLUSTER_TYPE
echo "Resource Group: $RESOURCE_GROUP_NAME"

# gibt es die ermittelte resourcengruppe bereit?
az group show --name $RESOURCE_GROUP_NAME > /dev/null
# falls nicht -> rg wird angeleget.
if [ $? -ne 0 ]; then
    echo "create resource group with name $RESOURCE_GROUP_NAME"
    az deployment sub create  \
        --location germanywestcentral \
        --template-file resource-group-template.json \
        --parameters @resource-group-parameters.json \
        --parameters rgName=$RESOURCE_GROUP_NAME
fi

SSHDIR=./.ssh
mkdir -p $SSHDIR
KEY_NAME=${SSHDIR}/${RESOURCE_GROUP_NAME}_id_rsa
echo "SSH Key Name : $KEY_NAME"
# generate new ssh key

if test -f "$KEY_NAME"; then
    echo "key $KEY_NAME already exists. None will be created"
else 
    ssh-keygen -m PEM -t rsa -b 4096 -f $KEY_NAME
fi

# laden den public Key
PUBLIC_KEY_DATA=$(<${SSHDIR}/${RESOURCE_GROUP_NAME}_id_rsa.pub)

TEMPLATE_DIR="./cluster/$CLUSTER_TYPE"
echo "TEMPLATE_DIR $TEMPLATE_DIR"

## https://docs.microsoft.com/de-de/azure/virtual-machines/extensions/custom-script-linux

# und dann das deployment starten...
echo "create deployment $RESOURCE_GROUP_NAME / $TEMPLATE_DIR"
output=$(az deployment group create -g $RESOURCE_GROUP_NAME \
    --template-file $TEMPLATE_DIR/template.json \
    --parameters @$TEMPLATE_DIR/paramerters.json \
    --parameters rgName=$RESOURCE_GROUP_NAME \
    --parameters clusterName="$CLUSTER_NAME" \
    --parameters publicKeyData="$PUBLIC_KEY_DATA")

echo $output > "./deploy.$CLUSTER_NAME.log"

if [ $? -ne 0 ]; then
    echo "deployed suceeded"
else
    echo "deployed faild"
    exit $?s
fi 