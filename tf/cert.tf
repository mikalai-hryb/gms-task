resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = "*.amazonaws.com"
    organization = var.domain
  }

  validity_period_hours = 24 * 365

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "self_signed" {
  private_key      = tls_private_key.this.private_key_pem
  certificate_body = tls_self_signed_cert.this.cert_pem
}
