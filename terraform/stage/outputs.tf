output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

output "db_internal_ip" {
  value = "${module.db.db_internal_ip}"
}

#output "lb_external_ip" {
#   value = "${google_compute_forwarding_rule.default.ip_address}"
#}

