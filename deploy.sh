#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
REGION=$REGION 
API_NAME=$API_NAME 
GATEWAY_NAME=$API_GATEWAY 
CONFIG_NAME=$API_CONFIG 
OPENAPI_SPEC="./swagger.yaml"
NEW_CONFIG_NAME=$NEW_API_CONFIG
SERVICE_ACCOUNT=$SERVICE_ACCOUNT    # Service account qui a le role run.invoker


echo "Activation des services necessaires..."
gcloud services enable \
  apigateway.googleapis.com \
  servicemanagement.googleapis.com \
  servicecontrol.googleapis.com \
  run.googleapis.com \
  iamcredentials.googleapis.com \
  compute.googleapis.com \
  --project=$PROJECT_ID


echo "Creation API"
gcloud api-gateway apis describe $API_NAME --project=$PROJECT_ID 2>/dev/null || \
  gcloud api-gateway apis create $API_NAME --project=$PROJECT_ID 


echo "Creation config API Gateway: $CONFIG_NAME si pas encore existe"
gcloud api-gateway api-configs create $CONFIG_NAME \
  --api=$API_NAME \
  --openapi-spec=$OPENAPI_SPEC \
  --project=$PROJECT_ID \
  --backend-auth-service-account=$SERVICE_ACCOUNT \
  || echo "La config $CONFIG_NAME existe peut-être déjà, passage à la suite..."


echo "Creation Gateway $GATEWAY_NAME"
gcloud api-gateway gateways create $GATEWAY_NAME \
  --api=$API_NAME \
  --api-config=$CONFIG_NAME \
  --location=$REGION \
  --project=$PROJECT_ID || echo "Deja cree"
sleep 20


echo "Recuperation du Gateway Host"
GATEWAY_HOST=$(gcloud api-gateway gateways describe $GATEWAY_NAME \
  --location=$REGION \
  --format="value(defaultHostname)" --project=$PROJECT_ID)


echo "MAJ du openapi.yaml du GATEWAY avec la bonne configuration"
sed -i "s|host: .*|host: $GATEWAY_HOST|" "$OPENAPI_SPEC"
sed -i "s|name: papiops.api|name: $GATEWAY_HOST|" "$OPENAPI_SPEC"
sleep 5

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


echo "describe api for enable"
gcloud api-gateway apis describe $API_NAME --project=$PROJECT_ID


echo "activer service enable managedservice Si on veut utiliser API_KEY | security active dans swagger"
echo "gcloud services enable xxxxxxxxxxxxx.apigateway.projectID.cloud.goog"
echo "SURA SURA PAPI"
