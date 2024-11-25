output "lb_url" {
  value = "https://${aws_lb.this.dns_name}:${aws_lb_listener.https.port}"
}

output "fully_qualified_tagged_image_name" {
  value = local.fully_qualified_tagged_image_name
}
