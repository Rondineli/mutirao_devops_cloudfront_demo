output "elb-dns" {
  value = aws_elb.elb.dns_name
}

output "cloudfront-domain" {
  value = aws_cloudfront_distribution.elb_distro.domain_name
}
