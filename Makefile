.PHONY: help all create

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  all         to create a k3d cluster"
	@echo "  create      to create a k3d cluster"


all: create

create:
	@echo "Creating k3d cluster"
	@k3d cluster create --config deploy/k3d.yaml --k3s-server-arg "--no-deploy=traefik" --k3s-server-arg "--no-deploy=servicelb"