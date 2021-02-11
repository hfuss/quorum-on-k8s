package racecourse

import (
	"github.com/gruntwork-io/terratest/modules/helm"
	networkingv1beta1 "k8s.io/api/networking/v1beta1"
	"testing"
)

const helmChartPath string = "./../"

func TestCertManagerAnnotation(t *testing.T) {
	certManagerAnnotation := "cert-manager.io/issuer"

	options := &helm.Options{

	}
	output := helm.RenderTemplate(t, options, helmChartPath, "unit-test", []string{"templates/ingress.yaml"})

	ingress := &networkingv1beta1.Ingress{}

	helm.UnmarshalK8SYaml(t, output, ingress)

	// ensure the cert-manager annotation equals {{ fullname }}-selfsigned, fullname == {{ release name }}-{{ chart name }}
	if ingress.Annotations[certManagerAnnotation] != "unit-test-racecourse-selfsigned" {
		t.Fatalf("Annotation templating not working as expected, '%s' was set to %s", certManagerAnnotation, ingress.Annotations[certManagerAnnotation])
	}

}
