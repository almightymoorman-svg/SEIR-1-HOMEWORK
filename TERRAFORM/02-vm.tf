resource "google_compute_instance" "centos_stream_10" {
  name         = "centos-stream-10"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  # boot disk using centos stream 10 image at 100GB
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-10"
      size  = 100
    }
  }

  # this puts the vm in a default vpc with an external ip
  network_interface {
    network = "default"

    access_config {} # assigns ephemeral external ip
  }


  # http-server tag required to allow port 80 which allows ssh
  tags = ["http-server"]



  metadata_startup_script = <<-EOF
   #!/bin/bash

# this just is to keep those next two commands readable. $META and $HEADER get replaced with these lines
META="http://metadata.google.internal/computeMetadata/v1/instance"
HEADER="Metadata-Flavor: Google"

# makes variables $NAME and $IP. Their values are from the curl command that hits the metadata service for VMs 
NAME=$(curl -H "$HEADER" "$META/name")
IP=$(curl -H "$HEADER" "$META/network-interfaces/0/ip")

# have the package manager grab the apache2 webserver 
dnf install -y httpd

# write our html file to the default location apache2 looks for
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<body>
  <h1>VM Metadata</h1>
  <h2>Instance Name: $NAME</h2>
  <h2>Internal IP: $IP</h2>
  <h2>Colombian prize included for free!</h2>
  <figure>
    <img src="https://test-1256099743.s3.us-east-2.amazonaws.com/Colombian/imgi_22_551283556_24677511425231259_7293143846320648055_n.jpg" alt="Colombian prize!" style="max-width:600px; width:100%; display:block; margin:1rem 0;">
    <figcaption>Colombian prize!</figcaption>
  </figure>
</body>
</html>
EOF

  # turn on apache2 service and make it turn on after the VM reboots too
}