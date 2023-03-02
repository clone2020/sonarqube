terraform {
    required_providers {

        aws = {
            source = "hashicorp/aws"
        }

        vault = {
            source = "hashicorp/vault"
        }

        null = {
            source = "hashicorp/null"
        }

        local = {
            source = "hashicorp/local"
        }

        template = {
            source = "hashicorp/template"
            version = "2.2.0"
        }
    }
}

provider "aws" {

#    shared_config_files = ["/home/rpullela/.aws/config"]
#    shared_credentials_files = ["/home/rpullela/.aws/credentials"]
#    profile = var.env

    default_tags {
        tags = {
            Name                       = "${var.app_name}-${var.env}"
            application-name           = var.app_name
            technical-contact          = var.technical_contact
            business-unit              = var.business_unit
            application-group          = var.application_group
            provisioned-by             = "rpullela@sworks.com"
            provisioning-tool          = "terraform"
            client-billable            = var.client_billable
            production                 = var.production
            exclude-from-low-utilization = false
            opt-in                     = true
        }
    }
  
}

provider "vault" {
    address = "https://vault.aws.sworks.com"
    
    auth_login {
        path = "auth/approle/login"

        parameters = {
            role_id = var.volsup_vault_approle_role_id
            secret_id = var.volsup_vault_approle_secret_id
        }
    }
}

provider "local" {
    # Configuration options
}

provider "null" {
    # Configuration options
}