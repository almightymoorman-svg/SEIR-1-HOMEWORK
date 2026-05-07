output "vm_name" {
  description = "Name of the VM"
  value       = google_compute_instance.centos_stream_10.name
}

output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = google_compute_instance.centos_stream_10.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "gcloud compute ssh ${google_compute_instance.centos_stream_10.name} --zone us-central1-a"
}

output "vm_internal_ip" {
  description = "Internal IP address of the VM"
  value       = google_compute_instance.centos_stream_10.network_interface[0].network_ip
}

output "instance_id" {
  description = "The unique server identifier"
  value       = google_compute_instance.centos_stream_10.id
}

output "instance_self_link" {
  description = "The URI of the created resource"
  value       = google_compute_instance.centos_stream_10.self_link
}