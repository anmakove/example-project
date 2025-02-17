resource "aws_appautoscaling_target" "atlantis_ecs" {
  max_capacity       = 1
  min_capacity       = 1
  resource_id        = "service/${module.atlantis.ecs_cluster_id}/${local.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_scheduled_action" "atlantis_switch_off_daily_midnight" {
  name               = "${local.name}-switch-off-daily-midnight"
  service_namespace  = aws_appautoscaling_target.atlantis_ecs.service_namespace
  resource_id        = aws_appautoscaling_target.atlantis_ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.atlantis_ecs.scalable_dimension
  schedule           = "cron(0 0 * * ? *)"
  timezone           = "Europe/Kiev"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

resource "aws_appautoscaling_scheduled_action" "atlantis_switch_off_daily_evening" {
  name               = "${local.name}-switch-off-daily-evening"
  service_namespace  = aws_appautoscaling_target.atlantis_ecs.service_namespace
  resource_id        = aws_appautoscaling_target.atlantis_ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.atlantis_ecs.scalable_dimension
  schedule           = "cron(0 21 * * ? *)"
  timezone           = "Europe/Kiev"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}
