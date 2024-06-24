#!/usr/bin/env bash

# This script rebuilds the complete minikube cluster in one shot,
# creating a ready-to-use WordPress + MariaDB + Minio environment.

echo ""
echo "••• Launching Minikube •••"
minikube start --memory 4096 --disk-size 60g --cpus 4
kubectl config use-context minikube

echo ""
echo "••• Installing Secrets •••"
kubectl apply -k secrets

echo ""
echo "••• Installing Minio •••"
kubectl apply -k minio

echo ""
echo "••• Installing MariaDB •••"
kubectl apply -k mariadb

echo ""
echo "••• Installing WordPress •••"
kubectl apply -k wordpress

echo ""
echo "••• Installing CRDs for K8up •••"
kubectl apply -f https://github.com/k8up-io/k8up/releases/download/v2.2.0/k8up-crd.yaml

echo ""
echo "••• Installing K8up •••"
helm repo add k8up-io https://k8up-io.github.io/k8up
helm repo update
helm install k8up-io/k8up --generate-name

echo "••• Wait for nodes become operational •••"
sleep 7*60
echo "••• Done •••"


echo "••• Running Shaduler •••"
source scripts/environment.sh

# Set Minikube context
kubectl config use-context minikube

# Set the schedule
kubectl apply -f sheduler/schedule.yaml