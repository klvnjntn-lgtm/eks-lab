resource "aws_ecr_repository" "guestbook_ui" {
  name                 = "guestbook-ui"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "Kelvin-Cloud-Infrastructure"
  }
}