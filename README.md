# Spark Minikube hostPath Volume

## Sample deploy of Spark in Minikube with shared hostPath volume

### Requirements

#### Install

1. [Spark](https://spark.apache.org/docs/3.3.1/#downloading) 3.3.1 hadoop 3 version.
1. [Docker](https://docs.docker.com/get-docker/).
1. [Minikube](https://minikube.sigs.k8s.io/docs/start/).
1. [Kubens](https://github.com/ahmetb/kubectx#installation)

### Setup

#### Start minikube

```sh
minikube start --cpus 4 --memory 8192
```

#### Create `SPARK_HOME` environment variable

```sh
export SPARK_HOME=<something>/spark-3.3.1-bin-hadoop3
```

#### Create docker image

```sh
$SPARK_HOME/bin/docker-image-tool.sh -m -t v3.3.1 build
```
Or if you need pyspark:
```sh
$SPARK_HOME/bin/docker-image-tool.sh -m -t v3.3.1 -p kubernetes/dockerfiles/spark/bindings/python/Dockerfile build
```

#### Share Minikube images with docker

```sh
eval $(minikube -p minikube docker-env)
docker images spark
```

#### Create Kubernet resources

From this git repo execute:

```sh
kubectl create -f k8s/rbac.yml
```
(thanks https://github.com/jaceklaskowski/spark-meetups)

#### Set default namespace

```sh
kubens spark-demo
```

#### Run Kubernetes dasboard

In another console run:
```sh
minikube dashboard
```
After a while the dashboard must be opened in your web browser.

### Run SparkPi example (without share folder)

You can run this simple program to test your deployment.

#### Execute

```sh
K8S_SERVER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}')
export POD_NAME=sparkpi-driver

$SPARK_HOME/bin/spark-submit --master k8s://$K8S_SERVER --deploy-mode cluster --name spark-pi --class org.apache.spark.examples.SparkPi \
    --conf spark.kubernetes.container.image=spark:v3.3.1 \
    --conf spark.kubernetes.driver.pod.name=$POD_NAME \
    --conf spark.kubernetes.context=minikube \
    --conf spark.kubernetes.namespace=spark-demo \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.executor.instances=3 --verbose \
    local:///opt/spark/examples/jars/spark-examples_2.12-3.3.1.jar 100
```

To show pod **logs**:
```sh
kubectl logs $POD_NAME
```
or use Kubernetes dashboard.

#### Spark Application Management

To show **status** of the running app:
```sh
$SPARK_HOME/bin/spark-submit \
  --master k8s://$K8S_SERVER \
  --status "spark-demo:$POD_NAME"
```

To **kill** app:
```sh
$SPARK_HOME/bin/spark-submit \
  --master k8s://$K8S_SERVER \
  --kill "spark-demo:$POD_NAME"
```


