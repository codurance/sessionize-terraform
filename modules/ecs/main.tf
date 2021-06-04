//resource "aws_ecr_repository" "this" {
//  count = length(var.app_list)
//  name = "sessionize-${var.env}-${var.app_list[count.index]}"
//}

resource "aws_ecs_cluster" "this" {
  name = "sessionize-${var.env}-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family = "sessionize"
  network_mode = "host"
  container_definitions = jsonencode([
    {
      name: "slackbot",
      cpu: 512,
      memory: 256,
      essential: true,
      image: "${aws_ecr_repository.this[0].repository_url}:latest",
      environment: [
        {
          name: "SLACK_BOT_TOKEN",
          value: local.SLACK_BOT_TOKEN
        },
        {
          name: "SLACK_SIGNING_SECRET",
          value: local.SLACK_SIGNING_SECRET
        },
        {
          name: "CORE_API",
          value: local.CORE_API
        }
      ]
    },
    {
      name: "core",
      cpu: 512,
      memory: 256,
      essential: true,
      image: "${aws_ecr_repository.this[1].repository_url}:latest",
      environment: [
        {
          name: "MONGODB_CONNECTION_STRING",
          value: local.MONGODB_CONNECTION_STRING
        },
        {
          name: "GOOGLE_CLIENT_ID",
          value: local.GOOGLE_CLIENT_ID
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name                 = "sessionize-ecs-service"
  cluster              = aws_ecs_cluster.this.id
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = 1
  force_new_deployment = true

  load_balancer {
    target_group_arn = aws_lb_target_group.http.arn
    container_name   = "slackbot"
    container_port   = 80
  }
}

resource "aws_launch_configuration" "this" {
  image_id = "ami-03e480ca5e6bab502" // eu-north-1 linux AMI
  iam_instance_profile = aws_iam_instance_profile.this.name
  security_groups = [aws_security_group.ec2.id]
  user_data = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config"
  instance_type = "t3.micro"
  key_name = "sessionize-test-slackbot"
}

resource "aws_autoscaling_group" "this" {
  name                      = "sessionize-${var.env}-asg"
  vpc_zone_identifier       = var.public_subnet_ids
  launch_configuration      = aws_launch_configuration.this.name
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
}