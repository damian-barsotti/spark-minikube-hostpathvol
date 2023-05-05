# Spark Minikube hostPath Volume

## Sample deploy of Spark in Minikube with shared hostPath volume

![Spark Kubernetes diagram](https://spark.apache.org/docs/3.3.1/img/k8s-cluster-mode.png)

See how `spark-submit` talks directly with Kubernetes API.

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
export SPARK_HOME="<something>/spark-3.3.1-bin-hadoop3"
```

#### Share Minikube images with docker (optional)

```sh
eval $(minikube -p minikube docker-env)
```

#### Create Kubernet resources

Change dir to this git repo execute:

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
After a while the dashboard should be opened in your web browser.

### Run SparkPi example (without shared folder)

You can run this simple program to test your deployment.

#### Execute

```sh
export K8S_SERVER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}')
export POD_NAME=sparkpi-driver
```
```sh
$SPARK_HOME/bin/spark-submit --master k8s://$K8S_SERVER --deploy-mode cluster \
    --name spark-pi --class org.apache.spark.examples.SparkPi \
    --conf spark.kubernetes.container.image=apache/spark:v3.3.1 \
    --conf spark.kubernetes.driver.pod.name=$POD_NAME \
    --conf spark.kubernetes.context=minikube \
    --conf spark.kubernetes.namespace=spark-demo \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.executor.instances=3 --verbose \
    local:///opt/spark/examples/jars/spark-examples_2.12-3.3.1.jar 100
```

To show the pod **logs**:
```sh
kubectl logs $POD_NAME
```
or use Kubernetes dashboard.

If you want to run again the example delete de driver pod:
```sh
kubectl delete pod $POD_NAME
```
or change `POD_NAME` environment variable, or delete conf `--conf spark.kubernetes.driver.pod.name=$POD_NAME`.

#### Spark Application Management

To show **status** of the running app:
```sh
$SPARK_HOME/bin/spark-submit \
  --master k8s://$K8S_SERVER \
  --status "spark-demo:$POD_NAME"
```

To **kill** the app:
```sh
$SPARK_HOME/bin/spark-submit \
  --master k8s://$K8S_SERVER \
  --kill "spark-demo:$POD_NAME"
```

### Run WordCount example (with `hostPath` shared folder)

#### Mount shared folder inside minikube

Open a new terminal window and from the folder of this repo keep running:
```sh
export MOUNT_PATH=/shared-folder
minikube mount --uid=185 ./shared-folder:$MOUNT_PATH
```

#### Run wordcount example

From the first terminal window run:

```sh
export K8S_SERVER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}')
export POD_NAME=wordcount-driver
export VOLUME_TYPE=hostPath
export VOLUME_NAME=demo-host-mount
export MOUNT_PATH=/shared-folder
```

```sh
$SPARK_HOME/bin/spark-submit --master k8s://$K8S_SERVER --deploy-mode cluster \
    --name wordcount --class WordCount \
    --conf spark.kubernetes.driver.volumes.$VOLUME_TYPE.$VOLUME_NAME.mount.path=$MOUNT_PATH \
    --conf spark.kubernetes.driver.volumes.$VOLUME_TYPE.$VOLUME_NAME.options.path=$MOUNT_PATH \
    --conf spark.kubernetes.executor.volumes.$VOLUME_TYPE.$VOLUME_NAME.mount.path=$MOUNT_PATH \
    --conf spark.kubernetes.executor.volumes.$VOLUME_TYPE.$VOLUME_NAME.options.path=$MOUNT_PATH \
    --conf spark.kubernetes.container.image=apache/spark:v3.3.1 \
    --conf spark.kubernetes.driver.pod.name=$POD_NAME \
    --conf spark.kubernetes.context=minikube \
    --conf spark.kubernetes.namespace=spark-demo \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.executor.instances=3 --verbose \
    local://$MOUNT_PATH/word_count/target/scala-2.12/wordcount_2.12-1.0.jar \
    $MOUNT_PATH/LICENSE $MOUNT_PATH/wc-out
```

### Write/read table with metastore db

```sh
kubectl apply -f metastore-mysql/mysql.yaml
```

```sh
export K8S_SERVER=$(kubectl config view --output=jsonpath='{.clusters[].cluster.server}')
export POD_NAME=test-metastore
export VOLUME_TYPE=hostPath
export VOLUME_NAME=demo-host-mount
export MOUNT_PATH=/shared-folder
```

```sh
$SPARK_HOME/bin/spark-submit --master k8s://$K8S_SERVER --deploy-mode cluster \
    --name test-metastore \
    --conf spark.kubernetes.driver.volumes.$VOLUME_TYPE.$VOLUME_NAME.mount.path=$MOUNT_PATH \
    --conf spark.kubernetes.driver.volumes.$VOLUME_TYPE.$VOLUME_NAME.options.path=$MOUNT_PATH \
    --conf spark.kubernetes.executor.volumes.$VOLUME_TYPE.$VOLUME_NAME.mount.path=$MOUNT_PATH \
    --conf spark.kubernetes.executor.volumes.$VOLUME_TYPE.$VOLUME_NAME.options.path=$MOUNT_PATH \
    --conf spark.kubernetes.container.image=damianbarsotti/spark-py:v3.3.1.0 \
    --conf spark.kubernetes.driver.pod.name=$POD_NAME \
    --conf spark.kubernetes.context=minikube \
    --conf spark.kubernetes.namespace=spark-demo \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.executor.instances=3 --verbose \
    --conf spark.hadoop.javax.jdo.option.ConnectionURL=jdbc:mysql://metastore-db/metastore \
    --conf spark.hadoop.javax.jdo.option.ConnectionUserName=root \
    --conf spark.hadoop.javax.jdo.option.ConnectionDriverName=com.mysql.cj.jdbc.Driver \
    --conf spark.hadoop.javax.jdo.option.ConnectionPassword=my-secret-pw \
    --conf spark.sql.warehouse.dir=$MOUNT_PATH/spark-warehouse \
    --verbose \
    local://$MOUNT_PATH/load_data_write_to_server.py
```

#### To see program's output:
```sh
kubectl logs test-metastore
```

### Thrift Server

```sh
kubectl apply -f spark-thrift-server/spark-thrift-server.yaml
```

#### Test thrift server:

```sh
export THRIFT_IP_PORT=$(minikube service -n spark-demo spark-thrift-server --url | cut -d/ -f 3)
```

```sh
$SPARK_HOME/bin/beeline  -u jdbc:hive2://$THRIFT_IP_PORT -n root
```

#### Kill server:

```sh
kubectl delete -f spark-thrift-server/spark-thrift-server.yaml
```
```sh
kubectl get pods --field-selector 'status.phase=Succeeded' -o name | xargs minikube kubectl -- delete
```

### Jupyter pyspark notebook

```sh
kubectl apply -f spark-thrift-server/spark-thrift-server.yaml
```
### Start jupyter in browser

```sh
minikube service -n spark-demo jupyter
```

#### Show token:

```sh
kubectl logs deployment/jupyter
```
or

```sh
kubectl exec deployment/jupyter -- jupyter server list --jsonlist
```

### `spark-shell` inside minikube

Run shell inside minikube:
```sh
./spark-bash.sh
```

Then, run `spark-shell`:
```sh
$SPARK_HOME/bin/spark-shell --master k8s://https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT --conf spark.driver.host=$SPARK_DRIVER_BIND_ADDRESS --conf spark.kubernetes.container.image=apache/spark:v3.3.1 --conf spark.kubernetes.context=minikube --conf spark.kubernetes.namespace=spark-demo  --verbose
```

Finally, copy and paste de following program:
```scala
val rdd = sc.parallelize(Array.range(1,100))
rdd.sum()
```
