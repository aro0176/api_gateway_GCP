# api_gateway_GCP
Automatisation de la Creation API Gateway pour GCP avec script Bash by PapiOPs

---
## Environnement
```bash
  export PROJECT_ID=$(gcloud config get-value project)
  export REGION= "us-central1"
  export API_NAME= "first-api"
  export GATEWAY_NAME= "first-api-gateway"
  export CONFIG_NAME= "first-api-config"
```
---
## Papi 1 : Activer services GCP

  ```bash
      gcloud services enable \
      apigateway.googleapis.com \
      servicemanagement.googleapis.com \
      servicecontrol.googleapis.com \
      run.googleapis.com \
      iamcredentials.googleapis.com \
      compute.googleapis.com \
      --project=$PROJECT_ID
  ```
  
---
## Papi 2: Creer API

- Faut creer l'API s'il n'a pas encore cree

  👉 Commande premiere creation :

 ```bash
  gcloud api-gateway apis create $API_NAME --project=$PROJECT_ID
 ```

---

## Papi 3: Creer Gateway

 ```bash
  gcloud api-gateway gateways create $GATEWAY_NAME --api=$API_NAME \
    --api-config=$CONFIG_NAME \
    --location=$REGION \
    --project=$PROJECT_ID || echo "Deja cree"

  gcloud api-gateway gateways describe $GATEWAY_NAME \
    --location=$REGION \
    --format="value(defaultHostname)
 ```

---

## Papi 4: Creer file YAML
  - Faut creer file openapi.yaml pour l'automatisation au format OpenAPI v2.0
  - Definir :

    - les routes (endpoints: /, /users, /list, ...)
    - l'url du backend dans `x-google-backend`
    - le host du futur API GATEWAY utilise par client
    - CORS avec `x-google-endpoints`.

  👉 Exemple de fichier `openapi.yaml` :
```yaml
swagger: "2.0"
info:
  title: papi script
  description: API Gateway by papiOps
  version: 1.0.0
host: {{URL_GATEWAY}}    #Change url par url publique du GATEWAY
paths:
  /endpoint:
    get:
      summary: Coucou
      operationId: getendpoint
      responses:
        '200':
          description: OK
      x-google-backend:
        address: {{SERVICE_URL}}
        protocol: h2
x-google-endpoints:
- name: {{URL_GATEWAY}}
  allowCors: true
```



## Papi 5: Creer une configuration d'API

- Associer le fichier openapi.yaml
- Cette config contient tous les details des routes et du backend

👉 Commande :

```bash
gcloud api-gateway api-configs create $CONFIG_NAME \
  --api=$API_NAME \
  --openapi-spec=openapi.yaml \
  --project=$PROJECT_ID
```

---

## Papi 6: Deployer le Gateway

- Creer un Gateway dans une REGION specifique
- Lier ce Gateway a la configuration precedente

👉 Commande :

```bash
gcloud api-gateway gateways create $GATEWAY_NAME \
  --api=$API_NAME \
  --api-config=$CONFIG_NAME \
  --location=$REGION \
  --project=$PROJECT_ID
```

---

## Papi 7: Tester l'API Gateway

- Recuperer URL publique du Gateway
  👉 Commande :

  ```bash
  gcloud api-gateway gateways describe $GATEWAY_NAME \
    --location=$REGION \
    --format="value(defaultHostname)"
  ```

- Envoyer des requetes HTTP via curl
  👉 Exemple :

  ```bash
  curl https://URL_GATEWAY/
  ```

---

## Papi 8:(Optionnel) Ajouter securite et authentification

- Ajouter des regles IAM pour restreindre l'acces
  👉 Exemple (lecture publique par tous) :

  ```bash
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="allUsers" \
    --role="roles/apigateway.invoker"
  ```

- Integrer l'authentification avec API Key, JWT, Google Identity
  👉 Exemples avances dans la [documentation officielle](https://cloud.google.com/api-gateway/docs/authenticating-users).

---

👨‍💻 Auteur : **PapiOps**   
📧 Contact : aandritoavina@gmail.com