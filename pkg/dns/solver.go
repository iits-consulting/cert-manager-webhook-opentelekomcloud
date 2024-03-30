package dns

import (
	"context"
	"fmt"
	"github.com/cert-manager/cert-manager/pkg/acme/webhook/apis/acme/v1alpha1"
	golangsdk "github.com/opentelekomcloud/gophertelekomcloud"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"log/slog"
)

const (
	solverReferenceName string = "opentelekomcloud"
)

// OpenTelekomCloudDnsProviderSolver implements the provider-specific logic needed to
// 'present' an ACME challenge TXT record for your own DNS provider.
// To do so, it must implement the `github.com/cert-manager/cert-manager/pkg/acme/webhook.Solver`
// interface.
type OpenTelekomCloudDnsProviderSolver struct {
	context   context.Context
	name      string
	k8sClient *kubernetes.Clientset
	dnsClient *golangsdk.ServiceClient
}

func NewOpenTelekomCloudDnsProviderSolver(ctx context.Context) *OpenTelekomCloudDnsProviderSolver {
	return &OpenTelekomCloudDnsProviderSolver{
		context: ctx,
		name:    solverReferenceName,
	}
}

// Name is used as the name for this DNS solver when referencing it on the ACME
// Issuer resource.
// This should be unique **within the group name**, i.e. you can have two
// solvers configured with the same Name() **so long as they do not co-exist
// within a single webhook deployment**.
// For example, `cloudflare` may be used as the name of a solver.
func (s *OpenTelekomCloudDnsProviderSolver) Name() string {
	return s.name
}

// Present is responsible for actually presenting the DNS record with the
// DNS provider.
// This method should tolerate being called multiple times with the same value.
// cert-manager itself will later perform a self check to ensure that the
// solver has correctly configured the DNS provider.
func (s *OpenTelekomCloudDnsProviderSolver) Present(ch *v1alpha1.ChallengeRequest) error {
	cfg, err := loadConfig(ch.Config)
	if err != nil {
		return err
	}

	// TODO: do something more useful with the decoded configuration
	fmt.Printf("Decoded configuration %v", cfg)

	// TODO: add code that sets a record in the DNS provider's console
	return nil
}

// CleanUp should delete the relevant TXT record from the DNS provider console.
// If multiple TXT records exist with the same record name (e.g.
// _acme-challenge.example.com) then **only** the record with the same `key`
// value provided on the ChallengeRequest should be cleaned up.
// This is in order to facilitate multiple DNS validations for the same domain
// concurrently.
func (s *OpenTelekomCloudDnsProviderSolver) CleanUp(ch *v1alpha1.ChallengeRequest) error {
	// TODO: add code that deletes a record from the DNS provider's console
	return nil
}

// Initialize will be called when the webhook first starts.
// This method can be used to instantiate the webhook, i.e. initialising
// connections or warming up caches.
// Typically, the kubeClientConfig parameter is used to build a Kubernetes
// client that can be used to fetch resources from the Kubernetes API, e.g.
// Secret resources containing credentials used to authenticate with DNS
// provider accounts.
// The stopCh can be used to handle early termination of the webhook, in cases
// where a SIGTERM or similar signal is sent to the webhook process.
func (s *OpenTelekomCloudDnsProviderSolver) Initialize(kubeClientConfig *rest.Config, stopCh <-chan struct{}) error {
	select {
	case <-s.context.Done():
		return s.context.Err()
	case <-stopCh:
		return fmt.Errorf(fmt.Sprintf(
			"initializing cert-manager webhook '%s' failed: early termination signal",
			solverReferenceName,
		))
	default:
	}

	client, err := kubernetes.NewForConfig(kubeClientConfig)
	if err != nil {
		return err
	}

	s.k8sClient = client

	slog.Debug(fmt.Sprintf("initialized cert-manager webhook '%s'", solverReferenceName))
	return nil
}
