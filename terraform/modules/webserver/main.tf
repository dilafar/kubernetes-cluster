resource "aws_security_group" "master-sg" {
  name        = "master-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }


  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 10250
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 4240
    to_port     = 4240
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "master-sg-dev"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}


resource "aws_security_group" "worker-sg" {
  name        = "worker-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 4240
    to_port     = 4240
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "worker-sg-dev"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}

resource "aws_iam_role" "ec2_worker_role" {
  name = "EC2WorkerAccessRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ec2_master_role" {
  name = "EC2MasterAccessRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ec2_worker_policy" {
  name        = "ec2WorkerPolicy"
  description = "Allows EC2 worker EC2 instances"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ec2_master_policy" {
  name        = "ec2MasterPolicy"
  description = "Allows EC2 master EC2 instances"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyVolume",
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteVolume",
        "ec2:DetachVolume",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DescribeVpcs",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:AttachLoadBalancerToSubnets",
        "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateLoadBalancerPolicy",
        "elasticloadbalancing:CreateLoadBalancerListeners",
        "elasticloadbalancing:ConfigureHealthCheck",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancerListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DetachLoadBalancerFromSubnets",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancerPolicies",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
        "iam:CreateServiceLinkedRole",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_worker_policy" {
  role       = aws_iam_role.ec2_worker_role.name
  policy_arn = aws_iam_policy.ec2_worker_policy.arn
}

# Create an instance profile
resource "aws_iam_instance_profile" "worker_instance_profile" {
  name = "WorkerNodeInstanceProfile"
  role = aws_iam_role.ec2_worker_role.name
}

resource "aws_iam_role_policy_attachment" "attach_master_policy" {
  role       = aws_iam_role.ec2_master_role.name
  policy_arn = aws_iam_policy.ec2_master_policy.arn
}

# Create an instance profile
resource "aws_iam_instance_profile" "master_instance_profile" {
  name = "MasterNodeInstanceProfile"
  role = aws_iam_role.ec2_master_role.name
}


/*data "aws_ami" "dev-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.ami_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  tags = {
    Name = "${var.env_prefix}-ami"
  }

}*/

resource "aws_key_pair" "dev-key" {
  key_name   = "kubeadm-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "k8-master" {
  ami                         = "ami-03e31863b8e1f70a5"
  instance_type               = var.instance_type_master
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.master-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.master_instance_profile.name

  #user_data = file("script.sh")
  #add master-slave tag to additional master node
  
  tags = {
    Name = "master-node"
    Node = "master"
    Cluster = "k8-kubeadm"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}

resource "aws_instance" "k8-master_2" {
  ami                         = "ami-03e31863b8e1f70a5"
  instance_type               = var.instance_type_master
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.master-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.master_instance_profile.name
  #user_data = file("script.sh")
  #add master-slave tag to additional master node
  
  tags = {
    Name = "master-node-2"
    Node = "master"
    Cluster = "k8-kubeadm"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}


resource "aws_instance" "k8-worker_1" {
  ami                         = "ami-03e31863b8e1f70a5"
  instance_type               = var.instance_type_worker
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.worker-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.worker_instance_profile.name
  #user_data = file("script.sh")
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  
  tags = {
    Name = "worker-node-1"
    Node = "worker"
    Cluster = "k8-kubeadm"
    "kubernetes.io/cluster/kubernetes" = "owned"
    "node.kubernetes.io/role"= "node"
  }

}


resource "aws_instance" "k8-worker_2" {
  ami                         = "ami-03e31863b8e1f70a5"
  instance_type               = var.instance_type_worker
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.worker-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.worker_instance_profile.name
  #user_data = file("script.sh")
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  
  tags = {
    Name = "worker-node-2"
    Node = "worker"
    Cluster = "k8-kubeadm"
    "kubernetes.io/cluster/kubernetes" = "owned"
    "node.kubernetes.io/role"= "node"
  }

}

resource "aws_instance" "k8-worker_3" {
  ami                         = "ami-03e31863b8e1f70a5"
  instance_type               = var.instance_type_worker
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.worker-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.worker_instance_profile.name
  #user_data = file("script.sh")
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  
  tags = {
    Name = "worker-node-3"
    Node = "worker"
    Cluster = "k8-kubeadm"
    "kubernetes.io/cluster/kubernetes" = "owned"
    "node.kubernetes.io/role"= "node"
  }

}

