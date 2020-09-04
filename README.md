# Provision Solace PS+ Container (HA) on Linux

## Ansible Roles

- docker: Install docker on the hosts
- vmr: Load the Solace docker image
- container: Create the solace container and start it
- ha: Create a solace PS+ HA triple
- sdkperf: Install sdkperf on the hosts

## Provision a single docker container

You should download the docker image first and put it in you local host, then update the `hosts` file according to your evn, then run the command `ansible-playbook -vv pubsub-single.yml`

### `hosts` file example

```ini
[all:vars]
ansible_connection=ssh
ansible_user=solace
ansible_ssh_pass=password
scale_tier="1k"
solace_docker_image_full_path="/tmp/solace-pubsub-evaluation-9.3.1.8-docker.tar.gz"

[all]
10.0.0.1
```

Where the `scale_tier` is choose from "1k", "10k", "100k" and "200k", the default value is "100".

## Provision a High Availability (HA) triple.

Run `ansible-playbook -vv pubsub-single.yml` first to load the Solace docker image into each host first, then run `ansible-playbook -vv pubsub-ha.yml` to create an HA triple.

### `hosts` file for HA example

**CAUTION**: There should be NO dash "-", No underline "_" and NO CAPITAL characters in the `router_name_suffix`. If you're going to form a DMR cluster, please make sure every broker node in the same DMR clust has a unique router name.

```ini
[all:vars]
ansible_connection=ssh
ansible_user=solace
ansible_ssh_pass=password
scale_tier="1k"
solace_docker_image_full_path="/tmp/solace-pubsub-evaluation-9.3.1.8-docker.tar.gz"
router_name_suffix=test
primary_ip=10.0.0.5
backup_ip=10.0.0.6
monitoring_ip=10.0.0.7

[all]
10.0.0.5 ha_role=primary
10.0.0.6 ha_role=backup
10.0.0.7 ha_role=monitoring
```
