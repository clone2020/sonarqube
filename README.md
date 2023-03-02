This code consists of packer, terraform, vault, consul, ansible for Sonarqube application on AWS.

To use the code you need to have AWS account and both the keys configure in .aws/credentials file.

To create AMI need to run the below code in packer folder.
# packer build .

Then run the below Terraform commands.

# terraform init

For test environment.

# terraform -chdir=./staging plan -out sonar_lab_plan

# terraform -chdir=./staging apply sonar_lab_plan

For prod environment.

# terraform -chdir=./production plan -out sonar_prod_plan

# terraform -chdir=./production apply sonar_prod_plan


