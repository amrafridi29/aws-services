# Fetch all available AZs in our chosen region
data "aws_availability_zones" "available" {
  state = "available"
}
