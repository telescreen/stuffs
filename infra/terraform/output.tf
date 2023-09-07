output "test_server_ip" {
  description = "all test servers ip address"
  value = tolist(openstack_compute_instance_v2.server[*].network[0].fixed_ip_v4)
}
