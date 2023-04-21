#!/bin/bash

TAG=mysql:8.0.31

minikube kubectl -- run -it --rm --image=$TAG --restart=Never mysql-bash -- /bin/bash
