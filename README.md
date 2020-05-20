# Googlesheet REST API
This repository creates Docker image which can be deployed on Docker, Kubernetes (GKE) and Google  Cloud Run.


- Go https://developers.google.com/console
- Enable APIs Sheet API and Drive API
- Create Service Account in GCP
- Go to your spreadsheet and share it with a client_email from the step above.

## Docker
 - Create a folder credentials/<file_name>.json
- Run following command to run docker container
```bash
docker run -v $PWD/credentials:/app/credentials -p 8080:8080 vikramshinde/config-service-googlesheet:latest
```


## Kubernets

- Create Service account in GCP
- Create Kubernetes cluster in GKE
- Create Kubernetes Secrete 
```bash 
kubectl create secret generic googlesheet-key --from-file=key.json=PATH-TO-KEY-FILE.json
```
- Deploy the Deployment and Service in Kubernetes
```bash
kubectl create -f kubernetes/.
```  

## Cloud Run

- Create Cloudbuild trigger 
- Select source as GITHUB
- Select environment variable _SERVICE_ACCOUNT_EMAIL  

The cloudbuild.yaml file will trigger the Cloud Build, 
push the image in Google Container Registry
and deploy the container in Cloud Run
