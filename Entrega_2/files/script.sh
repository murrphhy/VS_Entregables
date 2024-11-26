#!/bin/bash
kubectl create configmap drupal-env-config --from-env-file=.env
kubectl apply -f drupal-pvc.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f drupal-deployment-vs.yaml
kubectl apply -f mysql-deployment-vs.yaml
kubectl apply -f drupal-service-vs.yaml
kubectl apply -f mysql-service-vs.yaml
