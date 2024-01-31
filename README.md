# webMethods Vagrant sandbox

This repository contains a [Vagrant](https://www.vagrantup.com) VM to run webMethods products for local testing/debugging, using Docker.

## Prerequisites

Make sure you have [VirtualBox](https://www.virtualbox.org) and [Vagrant](https://www.vagrantup.com) installed before starting.

The VM will be created with 2 GB RAM, make sure your host machine has enough memory available.

## Usage

Start the VM by running `vagrant up` in the repository directory. The provisioning script will take some time to install and configure the node.

If an error occurs, you may try running `vagrant provision` to execute the script again.

After a few minutes, you should be able to access the Integration Server web interface at http://192.168.56.10:5555

You may get a shell in the VM with `vagrant ssh`, and run commands such as the following:
```
# Show container status
docker compose ps

# Show container logs
docker compose logs -f

# Restart containers
docker compose restart
```
