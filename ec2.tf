resource "aws_spot_instance_request" "sample" {
  count                   = local.LENGTH
  ami                     = ""
  spot_price              = "0.03"
  instance_type           = "t2.micro"
  wait_for_fulfillment    = true
  vpc_security_group_ids  = [aws_security_group.allow_ssh.id]
  tags = {
    Name                  = element(var.COMPONENTS, count.index)
  }
}


resource "aws_ec2_tag" "name-tag" {
  count                   = local.LENGTH
  resource_id             = element(aws_spot_instance_request.sample.*.spot_instance_id, count.index)
  key                     = "Name"
  value                   = element(var.COMPONENTS, count.index)
}

resource "null_resource" "run-shell-scripts" {
  count                   = local.LENGTH
  provisioner "remote-exec" {
    connection {
      host                = element(aws_spot_instance_request.sample.*.public_ip, count.index)
      user                = "centos"
      password            = "DevOps321"
    }

    command = [
    "cd /home/centos",
    "git clone https://github.com/vineethbandlamudi/shell-scripting.git",
    "cd shell-scripting/roboshop",
    "sudo make ${element(var.COMPONENTS, count.index)}"
    ]
  }
}

locals {
  LENGTH                   = length(var.COMPONENTS)
}