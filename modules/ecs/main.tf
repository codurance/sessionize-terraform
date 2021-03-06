resource "aws_ecs_cluster" "this" {
  name = "sessionize-${var.env}-cluster"
}

data "aws_ecr_repository" "slackbot" {
  name = var.slackbot-ecr
}

data "aws_ecr_repository" "core" {
  name = var.core-ecr
}

// TODO Working task definition
#{
#"ipcMode": null,
#"executionRoleArn": null,
#"containerDefinitions": [
#{
#"dnsSearchDomains": null,
#"environmentFiles": null,
#"logConfiguration": null,
#"entryPoint": null,
#"portMappings": [
#{
#"hostPort": 80,
#"protocol": "tcp",
#"containerPort": 80
#}
#],
#"command": null,
#"linuxParameters": null,
#"cpu": 512,
#"environment": [
#{
#"name": "CORE_API",
#"value": local.CORE_API
#},
#{
#"name": "PORT",
#"value": "80"
#},
#{
#"name": "SLACK_BOT_TOKEN",
#"value": local.SLACK_BOT_TOKEN
#},
#{
#"name": "SLACK_SIGNING_SECRET",
#"value": local.SLACK_SIGNING_SECRET
#}
#],
#"resourceRequirements": null,
#"ulimits": null,
#"dnsServers": null,
#"mountPoints": [],
#"workingDirectory": null,
#"secrets": null,
#"dockerSecurityOptions": null,
#"memory": 256,
#"memoryReservation": null,
#"volumesFrom": [],
#"stopTimeout": null,
#"image": "300563897675.dkr.ecr.eu-north-1.amazonaws.com/sessionize-dev-slackbot:latest",
#"startTimeout": null,
#"firelensConfiguration": null,
#"dependsOn": null,
#"disableNetworking": null,
#"interactive": null,
#"healthCheck": null,
#"essential": true,
#"links": [],
#"hostname": null,
#"extraHosts": null,
#"pseudoTerminal": null,
#"user": null,
#"readonlyRootFilesystem": null,
#"dockerLabels": null,
#"systemControls": null,
#"privileged": null,
#"name": "slackbot"
#},
#{
#"dnsSearchDomains": null,
#"environmentFiles": null,
#"logConfiguration": null,
#"entryPoint": null,
#"portMappings": [
#{
#"hostPort": 8080,
#"protocol": "tcp",
#"containerPort": 8080
#}
#],
#"command": null,
#"linuxParameters": null,
#"cpu": 512,
#"environment": [
#{
#"name": "GOOGLE_CLIENT_ID",
#"value": local.GOOGLE_CLIENT_ID
#},
#{
#"name": "MONGODB_CONNECTION_STRING",
#"value": local.MONGODB_CONNECTION_STRING
#}
#],
#"resourceRequirements": null,
#"ulimits": null,
#"dnsServers": null,
#"mountPoints": [],
#"workingDirectory": null,
#"secrets": null,
#"dockerSecurityOptions": null,
#"memory": 256,
#"memoryReservation": null,
#"volumesFrom": [],
#"stopTimeout": null,
#"image": "300563897675.dkr.ecr.eu-north-1.amazonaws.com/sessionize-dev-core:latest",
#"startTimeout": null,
#"firelensConfiguration": null,
#"dependsOn": null,
#"disableNetworking": null,
#"interactive": null,
#"healthCheck": null,
#"essential": true,
#"links": [],
#"hostname": null,
#"extraHosts": null,
#"pseudoTerminal": null,
#"user": null,
#"readonlyRootFilesystem": null,
#"dockerLabels": null,
#"systemControls": null,
#"privileged": null,
#"name": "core"
#}
#],
#"placementConstraints": [],
#"memory": null,
#"taskRoleArn": null,
#"compatibilities": [
#"EXTERNAL",
#"EC2"
#],
#"taskDefinitionArn": "arn:aws:ecs:eu-north-1:300563897675:task-definition/sessionize:85",
#"family": "sessionize",
#"requiresAttributes": [
#{
#"targetId": null,
#"targetType": null,
#"value": null,
#"name": "com.amazonaws.ecs.capability.ecr-auth"
#},
#{
#"targetId": null,
#"targetType": null,
#"value": null,
#"name": "com.amazonaws.ecs.capability.docker-remote-api.1.18"
#}
#],
#"pidMode": null,
#"requiresCompatibilities": [],
#"networkMode": "host",
#"runtimePlatform": null,
#"cpu": null,
#"revision": 85,
#"status": "ACTIVE",
#"inferenceAccelerators": null,
#"proxyConfiguration": null,
#"volumes": []
#}

resource "aws_ecs_task_definition" "this" {
  family = "sessionize"
  network_mode = "host"
  container_definitions = jsonencode([
    {
      name: "slackbot",
      cpu: 512,
      memory: 256,
      essential: true,
      image: data.aws_ecr_repository.slackbot.repository_url
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
      image: data.aws_ecr_repository.core.repository_url,
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