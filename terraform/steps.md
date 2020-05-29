## Deploy the CI/CD using Terraform
### Following steps will create resources in GCP project

- Google Cloud Repository
- Google Cloud Build
- Google Cloud Container Registry
- Google Cloud Run
1. Create Project
2. Create SA, Assign the roles: Editor, Security Admin, Service Usage Consumer, Source Repository Administrator 
and download key as terraform.json
3. export GOOGLE_CLOUD_KEYFILE_JSON=terraform-key.json
```
 git clone  https://github.com/vikramshinde12/config-service-googlesheet.git
 cd  config-service-googlesheet/terraform
``` 
4. terraform init
5. terraform plan
6. terraform apply

### Following steps to push the code into CSR
1. cd to root
``` 
cd..
```

2.  set remote
```shell script
git remote add google https://source.developers.google.com/p/[PROJECT_ID]/r/[REPO_NAME]
```

3. Push the code 
```shell script
git push --all google
```


#### If you want to maintain Terraform state in Google Cloud Storage 
1. export GCP_PROJECT={YOUR_PROJECT_ID}
2. export TF_STATE=${GCP_PROJECT}-state
3. gsutil mb -p ${GCP_PROJECT} gs://${TF_STATE}
4. cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_STATE}"
   prefix  = "terraform/state"
 }
}
EOF
4. gsutil versioning set on gs://${TF_STATE}
