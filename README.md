# Homework Assignment

## Tools used
    - kind
    - devcontainer
    - vscode with extensions
    - helm
    - kubectl

## Test environment
The test environment is automatically create when it is opened as devcontainer via vscode. As alternative the docker image can be
build  manually and started with the following command:

```
docker build -t "tag name of image" ./.devcontainer
docker run --rm -it -v .:/workspace/assignment "tag name of image" /bin/sh
```

### Spin up test cluster
To start the test cluster the following command has to be executed in the root folder of the project.

```
make start-env
```

It will start the dockerd service, sleep for 5 seconds to make shure dockerd is fully started and then
creates a kind cluster with the name kind-test.

There is also a stop-env command available to gracefully shut down the test system.

To verify cluster is up and running you can use

```
kubectl get nodes
```

This will use kubeconfig created from kind and connect to the cluster. If it shows a node with kind-test in name everthing is fine.

# Deployment 

## Install 
The deployment resulting from the instructions is located in src/deployment/chart/templates.
It is a helm chart which can be deployed using helm command. However before running the install command the namespace has to be created

```
kubectl create namespace project-plato
helm install project-plato src/deployment/chart -n project-plato
```

or

```
helm install project-plato src/deployment/chart -n project-plato --create-namespace
```

In the src/deployment folder there is also a manifist.yaml file which I created using the helm command.

```
helm template project-plato src/deployment/chart -n project-plato > src/deployment/manifest.yaml
```

To install it using the manifest

```
kubectl apply -f src/deployment/mainfest.yaml -n project-plato
```

## Uninstall
If you installed the deployment via helmchart. The command would be following.

```
helm uninstall project-plato -n project-plato
```

or 

```
kubectl delete -f src/deployment/manifest.yaml
```

This will not remove the namespace!


Hint: To not always have to sepcify the namespace in the command you can set the namespace used by the cli like this 
```
kubectl config set-context --namespace project-plato --current
```

Since the test env only has 1 cluster in the config. If there are multiple clusters then it will be a little bit tricky and you have to be careful to not modify the wrong config. I prefere to use the vscode kubernetes plugin for that kind of things.

# Validating Result
## 1.2 Unmodifiable Filesystem
To verify that no process inside the pod can modify the local file system you can run 

```
kubectl get pods -n project-plato
kubectl exec "replace with pod-name" -- /bin/sh -c 'echo "Test" > /test.txt' -n project-plato
```

To test if /tmp is writeable run the above command again, but replace "/test.txt" to "/tmp/test.txt"

## 1.5 Backend Liveness Probe & DB1 Readiness Probe
If liveness probe is working the container should be running without restarts but you can also check it when using

```
kubectl get pods -n project-plato
kubectl describe pod "replace with pod-name" -n project-plato
```

Then in the output of the command there is a section events where it would tell you if the probe fails. Same thing applies to the readiness probe.

## 1.6 Network Policy
To verify reachability through network policy you can run on backend pod

```
kubectl get pods -n project-plato
kubectl exec "replace with pod-name" -- /bin/sh -c 'nc -z db1 6379; echo $?'
``` 

If the connection to db1 on port 6379 is successful then a 0 would be returned otherwise a 1. To test other ports change the port value in the command.


## 1.7 Create Secret
A Kubernetes secret can be created by using the CLI or creating a yaml definition.

```
kubectl create secret generic cli-secret --from-literal=username=secret_user --from-literal=password=Pa55w.rd -n project-plato
```

To verify that the values of the secret created from helm deployment ar inside the backend you can run this command

```
kubectl get pods -n project-plato
kubectl exec "replace with pod-name" -- /bin/sh -c 'echo "${USERNAME} | ${PASSWORD}"' -n project-plato
```
# Design
The design diagrams are located in the architecture folder.

It uses Gitlab, Gitlab CI, Helm Charts, AWS EKS, AWS ALB for deployment purpose.
To improve security it uses a service mesh called istio. For monitoring grafan and prometheus would be install.
It is also possible to integrated elestisearch with promtail for log scraping. Which then also can be dsplayed in grafana dashboards.
