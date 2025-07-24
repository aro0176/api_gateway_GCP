#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
REGION=$REGION 
API_NAME=$API_NAME 
GATEWAY_NAME=$API_GATEWAY 
OPENAPI_SPEC="./swagger.yaml"
NEW_CONFIG_NAME=$NEW_API_CONFIG
SERVICE_ACCOUNT=$SERVICE_ACCOUNT

echo "Creation nouvelle config API avec host corrige: $NEW_CONFIG_NAME"
gcloud api-gateway api-configs create $NEW_CONFIG_NAME \
  --api=$API_NAME \
  --openapi-spec=$OPENAPI_SPEC \
  --project=$PROJECT_ID \
  --backend-auth-service-account=$SERVICE_ACCOUNT 

echo "MAJ du Gateway $GATEWAY_NAME"
gcloud api-gateway gateways update $GATEWAY_NAME \
  --api=$API_NAME \
  --api-config=$NEW_CONFIG_NAME \
  --location=$REGION \
  --project=$PROJECT_ID

echo "Recuperation de l'URL du Gateway"
GATEWAY_URL=$(gcloud api-gateway gateways describe $GATEWAY_NAME \
  --location=$REGION --format="value(defaultHostname)")

echo "Deploiement termine!"
echo "API Gateway URL: https://$GATEWAY_URL"

echo "SURA SURA PAPI"