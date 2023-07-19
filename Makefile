.PHONY: help all create

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  all         to create a k3d cluster"
	@echo "  create      to create a k3d cluster"


all: create

create:
	@echo "Creating Kind cluster"
	@kind create cluster --config deploy/kind-config.yaml
	@echo "Installing argocd"
	@kubectl create namespace argocd
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@kubectl patch cm/argocd-cm -n argocd --type=merge -p='{"data":{"resource.customizations.health.argoproj.io_Application":"hs = {}\nhs.status = \"Progressing\"\nhs.message = \"\"\nif obj.status ~= nil then\n  if obj.status.health ~= nil then\n    hs.status = obj.status.health.status\n    if obj.status.health.message ~= nil then\n      hs.message = obj.status.health.message\n    end\n  end\nend\nreturn hs\n"}}'
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
	@kubectl apply -n argocd -f deploy/argocd-nodeport.yaml
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d