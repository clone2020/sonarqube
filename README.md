This code consists of packer, terraform, vault, consul, ansible for Sonarqube application on AWS.

To use the code you need to have AWS account and both the keys configure in .aws/credentials file.

Use the below variable in .bashrc for the code to run smoothly.

# Export some env vars.
$ export CONSUL_HTTP_ADDR=https://consul.aws.secureworks.com
$ export VAULT_ADDR=https://vault.aws.secureworks.com
$ export TF_VAR_volsup_vault_approle_role_id=234532-2erf43-2435f-ertdf-54234gwge
$ export TF_VAR_volsup_vault_approle_secret_id= 1324gfq-345rerf-43e4-w4te-34234tr

# Terraform log and path
$ export TF_LOG=TRACE
$ export TF_LOG_PATH=/tmp/terraform-crash.log

# To create AMI need to run the below code in packer folder.
$ packer build .

# Then run the below Terraform commands.

$ terraform init

# For test environment.

$ terraform -chdir=./staging plan -out sonar_lab_plan

$ terraform -chdir=./staging apply sonar_lab_plan

# For prod environment.

$ terraform -chdir=./production plan -out sonar_prod_plan

$ terraform -chdir=./production apply sonar_prod_plan


