data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_vpc" "shivam_vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.shivam_vpc.id

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-igw" })

}

resource "aws_subnet" "public_subnet" {
  cidr_block              = var.public_subnet_cidr
  vpc_id                  = aws_vpc.shivam_vpc.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet1" })

}

resource "aws_subnet" "private_subnet" {
  cidr_block              = var.private_subnet_cidr
  vpc_id                  = aws_vpc.shivam_vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet2" })

}

# ROUTING #

# Public Route Table
resource "aws_route_table" "public_rtb" {
  vpc_id = "${aws_vpc.shivam_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-rtb" })
}

 # Private Route Table
resource "aws_default_route_table" "private_rtb" {
  default_route_table_id = "${aws_vpc.shivam_vpc.default_route_table_id}"

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-rtb" })
}

 #Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rtb.id
}

#Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_default_route_table.private_rtb.id
}

# SECURITY GROUPS #
resource "aws_security_group" "shivam-sg" {
  name   = "shivam_sg"
  vpc_id = aws_vpc.shivam_vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-sg" })
}

output "vpc_sg_id" {
  value = aws_security_group.shivam-sg.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}