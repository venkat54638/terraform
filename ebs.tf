# EBS Volumes
resource "aws_ebs_volume" "app_data" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  size              = var.ebs_volume_size
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "${var.project_name}-ebs-volume-${count.index + 1}"
  }
}

# Note: Attaching EBS volumes to Auto Scaling Group instances is complex in Terraform
# because ASG instance IDs are dynamic. Consider using a user data script or AWS Lambda
# to attach volumes post-instance launch. Below is a placeholder for manual attachment.
# resource "aws_volume_attachment" "app_data" {
#   count = 2
#   device_name = "/dev/sdf"
#   volume_id   = aws_ebs_volume.app_data[count.index].id
#   instance_id = aws_instance.web[count.index].id # Not applicable with ASG
# }