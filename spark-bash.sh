#!/bin/bash

TAG=damianbarsotti/spark:3.3.1

minikube kubectl -- run -it --rm --image=$TAG --restart=Never --image-pull-policy=Never spark-bash -- /bin/bash
