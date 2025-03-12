provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "tf-state-bucket-10101"
    key    = "rearc-quest-ecs/ecs/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "tf-state-bucket-10101"
    key            = "rearc-quest/vpc/terraform.tfstate"
    region         = "ap-south-1"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "task" {
  family                   = "ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
  {
    name      = "web",
    image     = "992382391803.dkr.ecr.ap-south-1.amazonaws.com/myecr/rearc-quest:4c3d0ef875a65d650dae0d61b92ecef7054b85da",
    essential = true,
    portMappings = [
      {
        containerPort = 3000
      }
    ],
      logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = "ecs-quest/task"
        awslogs-region = "${var.region}"
        awslogs-create-group = "true"
        awslogs-stream-prefix = "ecs"
      }
  }
    environment = [
      {
        name  = "SECRET_WORD"
        value = data.aws_secretsmanager_secret_version.quest_secret_version.secret_string
      } 
    ]
  }
])
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_groups = [data.terraform_remote_state.vpc.outputs.default_security_group_id]
    # assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "web"
    container_port   = 3000
  }
}
