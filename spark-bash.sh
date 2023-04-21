#!/bin/bash

SPARK_IM=${SPARK_IM:-damianbarsotti/spark-py:v3.3.1.0}

minikube kubectl -- run spark-bash -it --rm --image=$SPARK_IM --overrides='
{
	"kind": "Pod",
	"apiVersion": "v1",
	"metadata": {
		"name": "spark-bash",
		"namespace": "spark-demo"
    },
    "spec": {
        "containers": [
            {
                "name": "spark-bash",
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
                "terminationMessagePolicy": "FallbackToLogsOnError",
                "imagePullPolicy": "Always"
            }
        ],
        "restartPolicy": "Never",
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
