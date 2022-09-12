
# Neo4j Cluster ops on azure with ansible
This is just me practicing/having a bit of fun. For now keeping a very flat structure with a few playbooks and no fancy roles etc.

## Setup
Install ansible (run in python venv for instance)

Remark: On m1 mac I had issues with installing cryptography. Fix:
```shell
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"
```

```shell
python3 -m venv ansible
source ansible/bin/activate
python3 -m pip install ansible
python3 -m pip install "ansible-lint[yamllint]"
ansible-galaxy collection install azure.azcollection
python3 -m pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
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


## Autonomous Cluster

Initial exploration of the cluster
```
SHOW SERVERS;
CREATE DATABASE db1; // Defaults to 1 primary
CREATE DATABASE db2 OPTIONS {primaries: 3, secondaries:0};
```

Enable new servers
```
ENABLE SERVER "<uuid>" // two times
CREATE DATABASE db3 OPTIONS {primaries: 3, secondaries:2};
```

Show some other things
```
SHOW SERVERS YIELD name, address, state, health, hosting, requestedHosting, modeConstraint ORDER BY address;

// Are there any requestedHosting that is not fulfilled (if this makes sense at all?)
SHOW SERVERS YIELD name, address, state, health, hosting, requestedHosting, modeConstraint ORDER BY address
WHERE NOT all( n IN requestedHosting WHERE n IN hosting )
return *;
```

Deallocate and remove server
```
DEALLOCATE DATABASES FROM SERVER "<uuid>" // This will yield and error: Reallocation of 'DatabaseId{e223618c[db3]}' not possible, no new target found. (good!)
DROP DATABASE db3; 
DEALLOCATE DATABASES FROM SERVER "<uuid>"
DROP SERVER "<uuid>"

# from core5
sudo systemctl stop neo4j
sudo su neo4j
neo4j-admin server unbind
sudo systemctl start neo4j

SHOW SERVERS;  // Now with state free 
``

Enable it again
```
CALL unsupported.dbms.cluster.enableServer("<uuid>");
CREATE DATABASE db3 OPTIONS {primaries: 3, secondaries:2};
```


Other fun things
```
CREATE DATABASE db4 OPTIONS {primaries: 1, secondaries:4};


CREATE DATABASE movies OPTIONS { existingData: "use",
    seedURI: "file:///backup/movies.backup",
    primaries: 3, secondaries:2
};


```