# Spark Minikube hostPath Volume

## Sample deploy of Spark in Minikube with shared hostPath volume

### Instrucctions

#### Install

1. [Spark](https://spark.apache.org/docs/3.3.1/#downloading) 3.3.1 hadoop 3 version.
1. Install [Docker](https://docs.docker.com/get-docker/).
1. Install [Minikube](https://minikube.sigs.k8s.io/docs/start/).

#### Change dir into your Spark folder:
```sh
cd <something>/spark-3.3.1-bin-hadoop3/
```
#### Create docker image:

```sh
./bin/docker-image-tool.sh -m -t v3.3.1 build
```
o pyspark
```sh
./bin/docker-image-tool.sh -m -t v3.3.1 -p kubernetes/dockerfiles/spark/bindings/python/Dockerfile build
```
