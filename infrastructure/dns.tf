provider "cloudns" {
    rate_limit = 5 # default value
    auth_id = var.cloudns_auth_id
    password = var.cloudns_password
}

# resource "cloudns_dns_zone" "cloudns-zone" {
#     domain = "dancucluster.ip-ddns.com"
#     type = "master"
# }

resource "cloudns_dns_record" "node_1" {
    zone = "dancluster.ip-ddns.com"
    name = "node_1"
    type = "A"
    value = module.vm_1.external_ip
    ttl = 300
    depends_on = [module.vm_1]
}

resource "cloudns_dns_record" "node_2" {
    zone = "dancluster.ip-ddns.com"
    name = "node_2"
    type = "A"
    value = module.vm_2.external_ip
    ttl = 300
    depends_on = [module.vm_2]
}

resource "cloudns_dns_record" "node_3" {
    zone = "dancluster.ip-ddns.com"
    name = "node_3"
    type = "A"
    value = module.vm_3.external_ip
    ttl = 300
    depends_on = [module.vm_3]
}
