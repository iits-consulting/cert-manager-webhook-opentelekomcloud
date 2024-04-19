module github.com/akyriako/cert-manager-webhook-opentelekomcloud

go 1.21.4

require (
	github.com/caarlos0/env/v10 v10.0.0
	github.com/cert-manager/cert-manager v1.14.4
	github.com/go-logr/logr v1.4.1
	github.com/opentelekomcloud/gophertelekomcloud v0.9.2
	github.com/pkg/errors v0.9.1
	go.uber.org/zap v1.26.0
	k8s.io/api v0.29.3
	k8s.io/apiextensions-apiserver v0.29.3
	k8s.io/apimachinery v0.29.3
	k8s.io/client-go v0.29.3
	k8s.io/klog/v2 v2.110.1
	sigs.k8s.io/controller-runtime v0.16.3
)

require (
	github.com/miekg/dns v1.1.58 // indirect
	github.com/stretchr/testify v1.9.0 // indirect
)
