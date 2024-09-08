resource "yandex_vpc_network" "net" {
  name = "hexlet-ruslan-vpc"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "hexlet-ruslan-vpc"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.192.0/24"]
}


resource "yandex_compute_instance" "web" {
  count = 2

  name = "yc-web-server-${count.index}"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd82vchjp2kdjiuam29k"
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.vm_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_vpc_security_group" "vm_sg" {
  name        = "vm-security-group"
  description = "Security group for VM in Yandex Cloud"

  network_id = yandex_vpc_network.net.id

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 22
    to_port        = 22
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 80
    to_port        = 80
  }
}


variable "yc_iam_token" {}

resource "yandex_compute_instance" "default" {
  name        = "test"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  folder_id   = "b1gb1f1uhhr23g9upvk7"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.default.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet.id}"
    nat = true
  }


  # Inject the SSH key for user ruslan
  metadata = {
    "user-data" = <<-EOF
      #cloud-config
      users:
        - default
        - name: ruslan
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh-authorized-keys:
            - ${file("~/.ssh/id_ed25519.pub")}
    EOF
  }

  connection {
    type        = "ssh"
    user        = "ruslan"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.network_interface.0.nat_ip_address
  }


  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      <<EOT
sudo docker run -d -p 0.0.0.0:80:3000 \
  -e DB_TYPE=postgres \
  -e DB_NAME=${var.db_name} \
  -e DB_HOST=${yandex_mdb_postgresql_cluster.dbcluster.host.0.fqdn} \
  -e DB_PORT=6432 \
  -e DB_USER=${var.db_user} \
  -e DB_PASS=${var.db_password} \
  ghcr.io/requarks/wiki:2.5
EOT
    ]     
  
  }

}

resource "yandex_compute_disk" "default" {
  name     = "disk-name"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  image_id = "fd83s8u085j3mq231ago" // идентификатор образа Ubuntu
  folder_id = "b1gb1f1uhhr23g9upvk7"

  labels = {
    environment = "test"
  }
}
