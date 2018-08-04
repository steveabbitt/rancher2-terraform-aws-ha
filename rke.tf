# rke config yaml

data "template_file" "rke-yml" {
  template = "${file("3-node-externalssl-recognizedca.tpl")}"

  vars {
    RANCHER_URL = "${var.rancher_url}"
    IP01        = "${aws_instance.01.private_ip}"
    IP02        = "${aws_instance.02.private_ip}"
    IP03        = "${aws_instance.03.private_ip}"
    SSH_KEY     = "${var.rancher_name}"
  }
}

resource "null_resource" "rke-yml" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.rke-yml.rendered}\" > 3-node-externalssl-recognizedca.yml"
  }
}

# Upload yaml and ssh keys 

resource "null_resource" "rke-yml-upload" {
  depends_on = ["aws_eip_association.01", "aws_instance.02", "aws_instance.03"]

  provisioner "local-exec" {
    command = "sleep 300 && scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/${var.rancher_name}.pem 3-node-externalssl-recognizedca.yml ubuntu@${aws_eip.01.public_ip}:/home/ubuntu/"
  }
}

resource "null_resource" "ssh-key-upload-01" {
  depends_on = ["null_resource.rke-yml-upload"]

  provisioner "local-exec" {
    command = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/${var.rancher_name}.pem ~/.ssh/${var.rancher_name}.pem ubuntu@${aws_eip.01.public_ip}:/home/ubuntu/.ssh/"
  }
}

resource "null_resource" "ssh-key-upload-02" {
  depends_on = ["null_resource.rke-yml-upload"]

  provisioner "local-exec" {
    command = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/${var.rancher_name}.pem ~/.ssh/${var.rancher_name}.pem ubuntu@${aws_eip.02.public_ip}:/home/ubuntu/.ssh/"
  }
}

resource "null_resource" "ssh-key-upload-03" {
  depends_on = ["null_resource.rke-yml-upload"]

  provisioner "local-exec" {
    command = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/${var.rancher_name}.pem ~/.ssh/${var.rancher_name}.pem ubuntu@${aws_eip.03.public_ip}:/home/ubuntu/.ssh/"
  }
}

# Run rke deploy on first host

resource "null_resource" "deploy-rancher-cluster" {
  depends_on = ["null_resource.ssh-key-upload-01", "null_resource.ssh-key-upload-02", "null_resource.ssh-key-upload-03"]

  connection {
    host        = "${aws_eip.01.public_ip}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${tls_private_key.default.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "./rke up --config 3-node-externalssl-recognizedca.yml && sleep 10",
    ]
  }
}
