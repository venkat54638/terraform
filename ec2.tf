# User Data Script for EC2 instances
locals {
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd

    # Mount EBS volume (if attached)
    if [ -b /dev/xvdf ]; then
      mkfs -t ext4 /dev/xvdf
      mkdir /data
      mount /dev/xvdf /data
      echo '/dev/xvdf /data ext4 defaults,nofail 0 2' >> /etc/fstab
    fi

    # Create a simple web page
    echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
    echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
    echo "<p>EBS Volume mounted at /data</p>" >> /var/www/html/index.html
  EOF
}

# Launch Template for EC2 instances
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}