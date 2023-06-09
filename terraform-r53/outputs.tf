#name_servers
output "name_servers" {
    value = aws_route53_zone.main.name_servers
}
