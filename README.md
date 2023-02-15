# Spark Minikube hostPath Volume

## Sample deploy of Spark in Minikube with shared hostPath volume

### Instrucctions

#### Install

1. [Spark](https://spark.apache.org/docs/3.3.1/#downloading) 3.3.1 hadoop 3 version.
1. [Docker](https://docs.docker.com/get-docker/).
1. [Minikube](https://minikube.sigs.k8s.io/docs/start/).
1. [Kubens](https://github.com/ahmetb/kubectx#installation)

#### Change dir into your Spark folder:

```sh
cd <something>/spark-3.3.1-bin-hadoop3/
```
#### Create docker image:

```sh
./bin/docker-image-tool.sh -m -t v3.3.1 build
```
Or if you need pyspark
```sh
./bin/docker-image-tool.sh -m -t v3.3.1 -p kubernetes/dockerfiles/spark/bindings/python/Dockerfile build
```

#### Share Minikube images with docker:

```sh
eval $(minikube -p minikube docker-env)
docker images spark
```

#### Create Kubernet resources

From this git repo execute.

```sh
k create -f k8s/rbac.yml
```
(Thanks https://github.com/jaceklaskowski/spark-meetups)
