output "ec2_public_ip" {
  description = "Public IP of the Strapi EC2"
  value       = aws_instance.strapi_ec2.public_ip
}

output "strapi_url" {
  description = "Access Strapi at:"
  value       = "http://${aws_instance.strapi_ec2.public_ip}:1337"
}
