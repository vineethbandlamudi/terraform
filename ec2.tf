resource "aws_spot_instance_request" "sample" {
  count                   = local.LENGTH
  ami                     = "ami-0bb6af715826253bf"
  spot_price              = "0.0035"
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

resource "aws_route53_record" "records" {
  count                   = local.LENGTH
  name                    = element(var.COMPONENTS, count.index)
  type                    = "A"
  zone_id                 = "Z02459993QYCWJEXGK996"
  ttl                     = "300"
  records                 = [element(aws_spot_instance_request.sample.*.private_ip, count.index)]
}

resource "null_resource" "run-shell-scripts" {
  depends_on              = [aws_route53_record.records]
  count                   = local.LENGTH
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "centos"
      password            = "DevOps321"
      host                = element(aws_spot_instance_request.sample.*.public_ip, count.index)
    }

    inline = [
      "cd /home/centos",
      "git clone https://github.com/vineethbandlamudi/shell-scripting.git",
      "cd shell-scripting",
      "sudo make ${element(var.COMPONENTS, count.index)}"
    ]
  }
}

locals {
  LENGTH                   = length(var.COMPONENTS)
}