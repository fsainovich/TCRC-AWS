# TCRC-AWS
### The Cloud Resume Challenge - AWS

The challenge was proprosed by Forrest Brazeal in this website:

https://cloudresumechallenge.dev/ 

In his words: The Cloud Resume Challenge is a hands-on project designed to help you bridge the gap from cloud certification to cloud job. It incorporates many of the skills that real cloud and DevOps engineers use in their daily work.

The challenge has 16 items to complete.

In this REPO you can find my solution for all sections using a Terraform Module written by me.

### My site/resume is available in www.fsainovich.tec.br

## Requirements

* Linux distribution;
* AWS CLI installed and configured (IAM permissions for Terraform deploy the resources and Region = us-east-1);
* Terraform;
* GIT;
* A registered DOMAIN;


## Instructions
1. The code is configured to deploy resources in us-east-1 (in the future I will change the configs to deploy in any region using the VAR file);
2. Fill the variables file (terraform.tfvars) with your domain name in EACH FOLDER (terraform and terraform-r53); The only required value is the domain name, and terraform will does the magic !
3. Run the sequence terraform init -> terraform plan - terraform apply inside the folder terraform-r53. Why a separate folder for R53 Zone ?
    - 3.1. Short answer: Deploy the Zone separated to configure your DOMAIN provider with the authoritative DNS servers provided by R53 and wait propagation;
    - 3.2. Long answer: Every time you change your IAC (create and destroy the resouces) new authoritative DNS servers are provided by R53 and you need to change this values in your DOMAIN provider and wait the propagation of de DNS records (TTL), and trust me, this is a painful task. Because the ACM and Cloudfront require the propagation of the DNS records to complete yours owns configurations, run the tasks togheter will be return a fail state in Terraform. So, deploy your Zone, change your DOMAIN provider pointing to R53 DNS records and wait the propagation (in first and unique time that you need in this project, this task will be fast). You can check the state of your DNS in this website: https://www.nslookup.io/.
4. Is your DNS ok ? If yes, Let's run the sequence terraform init -> terraform plan -> terraform apply in terraform folder. So, what happens ?
    - 4.1. Terraform will deploy all AWS resources;
    - 4.2. Terrform will set the DynamoDB Table with 0 views;
    - 4.3. Terraform will set the Lambda Function URL in frontend JS code;
    - 4.4. Terraform Will push initial backend code to AWS CodeCommit REPO;
    - 4.5. Terraform Will push initial frontend code to AWS CodeCommit REPO;
    - 4.6. Terraform Will show te folow outputs:
        - 4.6.1. cloudfront_id;
        - 4.6.2. lambda_url;

5. Your website/resume will be acessilbe from https://yourdomain and https://www.yourdomain
