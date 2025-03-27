variable admin_public_ip {
    description = "The public IP address from which to allow SSH access"
    type = string
    default = "0.0.0.0/0"
}