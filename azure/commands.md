Commands
```bash
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

SSH in and watch it work:
```bash
cloud-init status --wait          # blocks until finished, prints "status: done"
sudo tail -f /var/log/cloud-init-output.log
```
Debugging Custom Data
```bash
cloud-init status --long                      # done, running, or error, with details
sudo cat /var/log/cloud-init-output.log       # output of your runcmd commands
sudo cat /var/log/cloud-init.log              # cloud-init's own detailed log
cloud-init schema --config-file cloud-init.yaml   # validate YAML before using it
```