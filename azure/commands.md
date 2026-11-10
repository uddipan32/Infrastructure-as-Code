Commands
```json
ssh-keygen -t ed25519 -f ~/.ssh/tf_azure -N ""     # once
az login
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
curl ifconfig.me                                    # put this IP in terraform.tfvars

terraform init
terraform plan
terraform apply
terraform output ssh_command                        # then run the printed command
terraform destroy
```