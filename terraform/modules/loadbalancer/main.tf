resource "aws_lb" "k8_master_nlb" {
  name               = "${var.env_prefix}-k8-master-nlb"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = var.subnet_id
  }

  tags = {
    Name = "${var.env_prefix}-k8-master-nlb"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# Create a Target Group for the master nodes
resource "aws_lb_target_group" "k8_master_target_group" {
  name        = "${var.env_prefix}-k8-master-tg"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol           = "TCP"
    port               = "6443"
    interval           = 30
    healthy_threshold  = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.env_prefix}-k8-master-tg"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

# Attach the master instances to the Target Group
resource "aws_lb_target_group_attachment" "k8_master_1_attachment" {
  target_group_arn = aws_lb_target_group.k8_master_target_group.arn
  target_id        = var.master_1_id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "k8_master_2_attachment" {
  target_group_arn = aws_lb_target_group.k8_master_target_group.arn
  target_id        = var.master_2_id
  port             = 6443
}

# Create a Listener for the NLB
resource "aws_lb_listener" "k8_master_listener" {
  load_balancer_arn = aws_lb.k8_master_nlb.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8_master_target_group.arn
  }
}