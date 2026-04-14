
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw-main"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = length(var.private_subnet_cidrs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "private_nat" {
  count = length(var.private_subnet_cidrs)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    "Name" = "${var.project_name}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  description       = "Allow HTTP traffic from internet"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  description       = "Allow HTTPS traffic from internet"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_out" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    "Name" = "${var.project_name}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  description                  = "Allow traffic from ALB to app servers"
}

resource "aws_vpc_security_group_egress_rule" "app_all_out" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic from app servers"
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow traffic from app servers to database"
}

resource "aws_vpc_security_group_egress_rule" "db_all_out" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic from database servers"
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Subnet group for RDS spans multiple AZs"
  subnet_ids  = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/db/password"
  type        = "SecureString"
  value       = random_password.db.result
  description = "RDS master password for ${var.project_name}"
}

resource "aws_db_parameter_group" "main" {
  name        = "${var.project_name}-pg15"
  family      = "postgres15"
  description = "Custom parameter group for PostgreSQL 15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # log queries slower than 1 second
  }

  tags = {
    Name = "${var.project_name}-pg15"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "15"
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  multi_az            = true
  publicly_accessible = false
  deletion_protection = false

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-db-final-snapshot"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name      = "${var.project_name}-db"
    ManagedBy = "Terraform"
  }
}

# With backup_retention_period = 7, 
# you can restore your database to any point in the last 7 days — down to the second. 
# This is invaluable when someone accidentally deletes production data.
# resource "aws_db_instance" "restored" {
#   identifier     = "${var.project_name}-db-restored"
#   instance_class = var.db_instance_class

#   restore_to_point_in_time {
#     source_db_instance_identifier = aws_db_instance.main.identifier
#     restore_time                  = "2024-01-15T03:00:00Z"
#     use_latest_restorable_time    = false
#   }

#   db_subnet_group_name   = aws_db_subnet_group.main.name
#   vpc_security_group_ids = [aws_security_group.db.id]
#   skip_final_snapshot    = true
# }

# Adding a Read Replica
# For high-read workloads, add a read replica — a separate instance that handles SELECT queries:

# resource "aws_db_instance" "read_replica" {
#   identifier          = "${var.project_name}-db-replica"
#   instance_class      = var.db_instance_class
#   replicate_source_db = aws_db_instance.main.identifier

#   # No db_name, username, password, subnet_group, parameter_group needed
#   # These are inherited from the source

#   vpc_security_group_ids = [aws_security_group.db.id]
#   storage_encrypted      = true
#   publicly_accessible    = false
#   skip_final_snapshot    = true

#   tags = {
#     Name      = "${var.project_name}-read-replica"
#     ManagedBy = "Terraform"
#   }
# }
