# Deploys Ecology Cluster on Amazon Web Services

## Deploy the Management Node

```
vagrant up mgmt
```

## Deploy the cluster

### Deploy the head node
```
export ECOLOGY_CLUSTER_NAME=a
vagrant up head
```

### Deploy the compute nodes
```
export ECOLOGY_CLUSTER_NAME=a
vagrant up
```

