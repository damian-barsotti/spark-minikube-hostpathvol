#!/bin/bash

SPARK_IM=${SPARK_IM:-damianbarsotti/spark-py:v3.3.1.0}
POD_NAME=spark-bash

minikube kubectl -- run $POD_NAME --namespace=spark-demo -it --rm --image=$SPARK_IM --overrides='
{
	"kind": "Pod",
	"apiVersion": "v1",
	"metadata": {
		"name": "'$POD_NAME'",
		"namespace": "spark-demo"
    },
    "spec": {
        "containers": [
            {
                "name": "'$POD_NAME'",
                "image": "'$SPARK_IM'",
                "command": ["/opt/entrypoint.sh"],
                "args": ["/bin/bash"],
                "stdin": true,
                "tty": true,
                "volumeMounts": [
                    {
                        "name": "shared-volume",
                        "mountPath": "/shared-folder"
                    }
                ],
                "env": [
                    {
                        "name": "SPARK_USER",
                        "value": "damian"
                    },
                    {
                        "name": "SPARK_DRIVER_BIND_ADDRESS",
                        "valueFrom": {
                            "fieldRef": {
                                "apiVersion": "v1",
                                "fieldPath": "status.podIP"
                            }
                        }
                    },
                    {
                        "name": "SPARK_CONF_DIR",
                        "value": "/opt/spark/conf"
                    }
                ],
                "terminationMessagePolicy": "FallbackToLogsOnError",
                "imagePullPolicy": "Always"
            }
        ],
        "restartPolicy": "Never",
        "serviceAccountName": "spark",
        "serviceAccount": "spark",
        "volumes": [
            {
                "name": "shared-volume",
                "hostPath": {
                    "path": "/shared-folder/"
                }
            }
        ]
    }
}
'
