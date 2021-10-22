# CQPweb Deployment Scripts

This repository comes with Terraform scripts for installing provisioning cloud infrastructure, installing required software and finally CQPweb, a corpus analysis linguistic tool. Specifically, we use these scripts to setup CQPweb at <https://cqpweb.corpuslinguist.com/>, but anybody can use them.

In specifics, the scripts (if used in default state), will:

- provision a Droplet (with a volume) on DigitalOcean
- install NginX webserver
- setup firewall
- clone CQPweb and related software from <https://github.com/bbatalo/CQPweb>
- install PHP
- install R
- install and setup MySQL
- install CWB
- install CWB Perl modules
- install CQPweb to webserver
- setup webserver rules for CQPweb
- setup directories for CQPweb data (corpora, registry, upload, temp)
- restart required services (AppArmor, NginX, firewall)

The scripts _do not_ setup CQPweb (by running autosetup.php). This step as to be performed manually due to security reasons, as it includes setting up user passwords for admin accounts of CQPweb.

## Prerequisites

To use these scripts, two things are required: installed Terraform CLI and DigitalOcean API CLI. The first one is used for running the scripts, the second for accessing DigitalOcean services automatically. Both of these tools are to be installed on the local machine - the one from which the scripts are to be ran. CQPweb will be installed in the remote (cloud) machine.

To install Terraform, follow steps for your OS -> [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

To install DigitalOcean CLI (doctl), follow steps for your OS -> [Install doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/). Using this will also require a DigitalOcean account, and an access token to be able to use the API.

## How to use

Terraform is an infrastructure as code software tool which enables provisioning and maintenance of cloud services. We will explain only the basics of Terraform here. For further information, please visit official documentation at <https://www.terraform.io/docs/index.html>.

### Running the scripts

Having setup Terraform and DigitalOcean CLI, installing CQPweb is as simple as running the following two commands. We recommend running them one by one and inspecting the output of each command. The first command, `terraform plan` will create a Terraform plan, which outlines infrastructure (containing CQPweb) which will be created. The second command, `terraform apply` executes the plan and creates outlined infrastructure.

_Note_: Before running, please add your public key to line 12 of `scripts/add-setup-cqpweb.yaml`. In future versions we will try to make this automatic.

```bash
terraform plan \
  -var "do_token=${DO_PAT}" \
  -var "pvt_key=$HOME/.ssh/id_rsa"
```

```bash
terraform apply \
  -var "do_token=${DO_PAT}" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
```

Following successfull execution of commands, it is possible to access the cloud machine by running:

```bash
ssh terraform@cloud_ip_address
```

where _cloud_ip_address_ is the public IP address of the cloud machine. This IP can be found either in the output of `terraform apply` command, or in the DigitalOcean control panel. As you can see, a Unix user `terraform` is created in the cloud and can be used to run commands over ssh.

#### Setting up CQPweb

Final step is to configure CQPweb using the ``autosetup.php` script.

First, access the cloud machine and navigate to the location of this script (default - /var/www/cqpweb.com//bin), then run the `autosetup.php` script, like this:

```bash
ssh terraform@cloud_ip_address

cd /var/www/cqpweb.com/bin/ && sudo php autosetup.php
```

Follow the steps to supply the script with admin passwords, and you're good to go! Access CQPweb via your public IP address.

Optionally, secure your deployed server by enabling HTTPS (highly recommended), for which you need to register a domain, and install a certificate on the cloud machine. This requires only a couple of steps, and DigitalOcean provides an excellent tutorial on how to do it in their [documentation](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04).

#### Destroying the infrastructure

To destroy created infrastructure, run the following two commands.

```bash
terraform plan -destroy -out=terraform.tfplan \
  -var "do_token=${DO_PAT}" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
```

```bash
terraform apply terraform.tfplan
```

## Final notes

It is possible to extend these scripts to support any cloud service provider, aside from Digitalocean. However, this would require creating a new pair of`provider.tf` and `cqpweb.tf` files, which contain defined interactions with the specified provider's API.
