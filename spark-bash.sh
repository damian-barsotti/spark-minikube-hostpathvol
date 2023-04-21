#!/bin/bash

TAG=damianbarsotti/spark-py:v3.3.1.0

#minikube kubectl -- run -it --rm --image=$TAG --restart=Never spark-bash -- /bin/bash

minikube kubectl -- run spark-bash -it --rm --image=$TAG --overrides='
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
                "image": "'$TAG'",
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
