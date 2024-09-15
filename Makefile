start-env:
	mkdir -p /tmp/user/0
	dockerd-entrypoint.sh &
	sleep 5
	kind create cluster --name test

stop-env:
	kind delete cluster --name test
	pkill -KILL dockerd

install:
	helm install project-plato src/deployment/chart -n project-plato --create-namespace

uninstall:
	helm uninstall project-plato -n project-plato

upgrade:
	helm upgrade project-plato src/deployment/chart -n project-plato

template:
	helm template project-plato src/deployment/chart -n project-plato > src/deployment/manifest.yaml