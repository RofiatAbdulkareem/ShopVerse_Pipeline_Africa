# resource "aws_vpc" "redshift_vpc" {
#   cidr_block = "10.1.0.0/16"
#   tags = {
#     Name = "shopverse"
#   }
# }

# resource "aws_subnet" "rs_public_subnet_1" {
#   cidr_block        = "10.1.1.0/24"
#   availability_zone = "us-east-1a"
#   vpc_id            = aws_vpc.redshift_vpc.id

#   tags = {
#     Name = "rs-public_subnet_1"
#   }
# }

# resource "aws_subnet" "rs_public_subnet_2" {
#   cidr_block        = "10.1.2.0/24"
#   availability_zone = "us-east-1b"
#   vpc_id            = aws_vpc.redshift_vpc.id

#   tags = {
#     Name = "rs_public_subnet_2"
#   }
# }

# resource "aws_internet_gateway" "redshift-igw" {
#   vpc_id = aws_vpc.redshift_vpc.id

#   tags = {
#     Name = "redshift-igw"
#   }
# }

# resource "aws_route_table" "redshift_rt" {
#   vpc_id = aws_vpc.redshift_vpc.id

#   tags = {
#     Name = "redshift_rt"
#   }
# }

# resource "aws_route" "redshift_route" {
#   route_table_id         = aws_route_table.redshift_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.redshift-igw.id
# }

# resource "aws_route_table_association" "public_subnet_1_association" {
#   subnet_id      = aws_subnet.rs_public_subnet_1.id
#   route_table_id = aws_route_table.redshift_rt.id
# }

# resource "aws_route_table_association" "public_subnet_2_association" {
#   subnet_id      = aws_subnet.rs_public_subnet_2.id
#   route_table_id = aws_route_table.redshift_rt.id
# }

# resource "aws_redshift_subnet_group" "rs_subnet_group" {
#   name       = "rs-subnet-group"
#   subnet_ids = [aws_subnet.rs_public_subnet_1.id, aws_subnet.rs_public_subnet_2.id]
# }

# resource "aws_iam_role" "redshift_role" {
#   name = "redshift_role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "redshift.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_policy" "redshift_policy" {
#   name = "redshift_policy"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:ListAllBuckets",
#           "redshift:*"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "redshift_role_policy_attachment" {
#   name       = "redshift_role_policy_attachment"
#   roles      = [aws_iam_role.redshift_role.name]
#   policy_arn = aws_iam_policy.redshift_policy.arn
# }

# resource "aws_redshift_cluster_iam_roles" "redshift_cluster_iam_roles" {
#   cluster_identifier = aws_redshift_cluster.redshift_cluster.cluster_identifier
#   iam_role_arns      = [aws_iam_role.redshift_role.arn]
# }

# resource "aws_ssm_parameter" "redshift_db_username" {
#   name  = "redshift_db_username"
#   type  = "String"
#   value = "rofiat"
# }

# resource "random_password" "password" {
#   length  = 8
#   special = false
# }

# resource "aws_ssm_parameter" "redshift_db_password" {
#   name  = "redshift_db_password"
#   type  = "String"
#   value = random_password.password.result
# }

# resource "aws_redshift_cluster" "redshift_cluster" {
#   cluster_identifier        = "redshift-cluster"
#   database_name             = "shopverse_db"
#   master_username           = aws_ssm_parameter.redshift_db_username.value
#   master_password           = aws_ssm_parameter.redshift_db_password.value
#   node_type                 = "ra3.large"
#   cluster_type              = "multi-node"
#   cluster_subnet_group_name = aws_redshift_subnet_group.rs_subnet_group.name
#   iam_roles                 = [aws_iam_role.redshift_role.arn]
#   number_of_nodes           = 2
#   publicly_accessible       = true
# }

# resource "aws_security_group" "redshift_SG" {
#   name        = "allow_traffic"
#   description = "Allow inbound traffic and outbound"
#   vpc_id      = aws_vpc.redshift_vpc.id

#   tags = {
#     Name = "redshift-SG"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
#   security_group_id = aws_security_group.redshift_SG.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 5439
#   ip_protocol       = "tcp"
#   to_port           = 5439
# }

# resource "aws_vpc_security_group_egress_rule" "egress_rule" {
#   security_group_id = aws_security_group.redshift_SG.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports,allow all types of ip-protocol
# }

# resource "aws_redshift_parameter_group" "redshift_parameter_group" {
#   name   = "redshift-parameter-group"
#   family = "redshift-2.0"

#   parameter {
#     name  = "require_ssl"
#     value = "false"
#   }
# }