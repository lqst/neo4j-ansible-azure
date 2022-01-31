
# Neo4j Cluster ops on azure with ansible
This is just me practicing/having a bit of fun. For now keeping a very flat structure with a few playbooks and no fancy roles etc.

## Setup
Install ansible (run in python venv for instance)

```shell
python3 -m venv ansible
source ansible/bin/activate
python3 -m pip install ansible
python3 -m pip install "ansible-lint[yamllint]"
ansible-galaxy collection install azure.azcollection
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
```


### Inventory (dev/)
Currently using KEY_DATA to store my public ssh key in dev/group_vars/all.yml (update accordingly)


## Tricks

### List hosts with az cli
I have not found a clean way of doing it with ansible...
```bash
az vm list-ip-addresses --query "[*].virtualMachine.{name: name, ip: network.publicIpAddresses[0].ipAddress}" -o tsv
```

### Print out hostvars
ansible tag_applicationRole_corenode -m debug -a 'var=hostvars' -i dev

### Print public ip addresses
ansible tag_applicationRole_corenode -m debug -a 'var=ansible_host' -i dev

## Todo

- [ ] Better check for healthy cluster on rolling upgrade
- [x] Additional NIC for intra cluster communication
- [ ] Move things to the right places