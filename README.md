# provisioning of ASTPP

Repository with material used to provision ASTPPs in the cloud.

## Tools used

- `Terraform` for creating instances on AWS.
- `Ansible` for provisioning.

## Tutorial

Here is a step by step how to proceed with the installation:

### Terraform

Use a command `ssh-keygen` to create a SSH key pair (If you don't already have it).

In the terraform directory, use the command `terraform init` to load the necessary modules.

Edit the contents of the file `terraform.tfvars` to select your variables.

Use the `terraform apply` command to create the required resources on AWS.

### Ansible

Add the hosts created on terraform to the ansible inventory.

Run the commands below to install some dependencies:

- `ansible-galaxy collection install community.crypto`
- `ansible-galaxy install gantsign.oh-my-zsh`

In ansible directory, edit a `playbook.yml` with the correct variables (like a `terraform.tfvars`).

Run `ansible-playbook playbook.yml` in ansible directory.

## License

See [LICENSE.md](./LICENSE.md) for more details.

## Author

| [<img src="https://avatars0.githubusercontent.com/u/26543872?v=3&s=115"><br><sub>@Otoru</sub>](https://github.com/Otoru) |
| :----------------------------------------------------------------------------------------------------------------------: |