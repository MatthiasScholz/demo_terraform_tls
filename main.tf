provider "tls" {
  version = "~> 1.2"
}

provider "local" {
  version = "~> 1.1"
}

resource "tls_private_key" "acme_ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "acme_ca_key" {
  content  = "${tls_private_key.acme_ca.private_key_pem}"
  filename = "${path.module}/certs/acme_ca_private_key.pem"
}

resource "tls_self_signed_cert" "acme_ca" {
  key_algorithm     = "RSA"
  private_key_pem   = "${tls_private_key.acme_ca.private_key_pem}"
  is_ca_certificate = true

  subject {
    common_name         = "Acme Self Signed CA"
    organization        = "Acme Self Signed"
    organizational_unit = "acme"
  }

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "local_file" "acme_ca_cert" {
  content  = "${tls_self_signed_cert.acme_ca.cert_pem}"
  filename = "${path.module}/certs/acme_ca.pem"
}

resource "tls_private_key" "example_com" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "example_com_key" {
  content  = "${tls_private_key.example_com.private_key_pem}"
  filename = "${path.module}/certs/example_com_private_key.pem"
}

resource "tls_cert_request" "example_com" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.example_com.private_key_pem}"

  dns_names = ["example.com"]

  subject {
    common_name         = "example.com"
    organization        = "Example Self Signed"
    country             = "US"
    organizational_unit = "example.com"
  }
}

resource "tls_locally_signed_cert" "example_com" {
  cert_request_pem   = "${tls_cert_request.example_com.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.acme_ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.acme_ca.cert_pem}"

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "example_com_cert_pem" {
  content  = "${tls_locally_signed_cert.example_com.cert_pem}"
  filename = "${path.module}/certs/example_com_cert.pem"
}
