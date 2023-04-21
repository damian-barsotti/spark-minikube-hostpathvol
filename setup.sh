minikube start --cpus 4 --memory 8192

if [ -z "$SPARK_HOME" ] || ![ -d "$SPARK_HOME" ]
then
    export SPARK_HOME=$HOME/spark//spark-3.3.1-bin-hadoop3
fi

eval $(minikube -p minikube docker-env -u)
eval $(minikube -p minikube docker-env)

minikube kubectl -- create -f k8s/rbac.yml

kubens spark-demo

minikube kubectl -- apply -f metastore-mysql/mysql.yaml

echo In other consoles run:
echo minikube dashboard
echo minikube mount --uid=185 ./shared-folder:/shared-folder
