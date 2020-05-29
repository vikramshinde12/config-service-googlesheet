# Googlesheet REST API
This repository creates Docker image which can be deployed on Docker, Kubernetes (GKE) and Google  Cloud Run.


- Go https://developers.google.com/console
- Enable APIs Sheet API and Drive API
- Create Service Account in GCP and download it as client-secret.json
- Go to your spreadsheet and share it with a client_email from the step above.

## Docker
 - Create a folder credentials and copy client-secret.json
- Run following command to run docker container
```bash
docker run -v $PWD/credentials:/app/credentials -p 8080:8080 vikramshinde/config-service-googlesheet:latest
```


## Kubernets
- Create Kubernetes cluster in GKE
- Go to Cloud shell and connect to cluster
- Create Kubernetes Secret 
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
- Select environment variables
   _SERVICE_ACCOUNT_EMAIL client-email from client-secret.json
   _REGION as 'us-central1'
   _SERVICE_NAME as 'config-service'

The cloudbuild.yaml file will trigger the Cloud Build, 
push the image in Google Container Registry
and deploy the container in Cloud Run


## Terraform
Automatically deploy CI/CD pipeline into GCP environment.

Follow the steps mentioned in the terraform/steps.md

For details terraforming steps [please refer the blog](https://medium.com/@vikramshinde/deploy-ci-cd-pipeline-on-gcp-using-terraform-364e533dd465)