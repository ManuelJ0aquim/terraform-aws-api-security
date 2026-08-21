# Log Group do CloudWatch para o WAF
# Nota: O nome OBRIGATORIAMENTE precisa começar com 'aws-waf-logs-'
resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "aws-waf-logs-api-protection"
  retention_in_days = 7
}

# Ativação do envio de logs do WAF para o CloudWatch
resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.waf_acl.arn
}

# Alarme no CloudWatch para disparar quando houver bloqueios
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests_alarm" {
  alarm_name          = "WAF-High-Blocked-Requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Dispara quando o WAF bloqueia mais de 10 requisicoes em 5 minutos"

  dimensions = {
    WebACL = aws_wafv2_web_acl.waf_acl.name
    Region = var.aws_region
    Rule   = "ALL"
  }
}

# Exibe a URL final da API ao concluir o terraform apply
output "api_url" {
  value       = "${aws_api_gateway_stage.prod.invoke_url}/"
  description = "URL de invocacao da API REST"
}