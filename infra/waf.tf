resource "aws_wafv2_ip_set" "denied_ips" {
  name               = "denied-ips-set"
  description        = "Lista de IPs bloqueados manualmente"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.0/24", "198.51.100.10/32"]
}

resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "waf-api-protection"
  description = "WAF ACL para protecao de API Gateway"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Regra 1: Rate Limiting por IP
  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regra 2: Proteção Genérica OWASP Top 10
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regra 3: Proteção de SQL Injection (SQLi)
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regra 4: IP Filtering (Filtro por IP Set)
  rule {
    name     = "IPFilteringRule"
    priority = 4

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.denied_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPFilteringRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regra 5: Geo Blocking (Restrição Geográfica)
  rule {
    name     = "GeoBlockingRule"
    priority = 5

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["CN", "RU", "KP", "SA", "BR", "CO", "VE", "PY", "PA", "EC", "NI", "DO", "PE", "HN", "GT", "BO", "US"] # Bloqueia China, Rússia e Coreia do Norte, Arabia Saudita, Brasil, Colombia, Venezuela, Paraguay, Panama, Ecuador, Nicaragua, Dominican Republic, Peru, Honduras, Guatemala, Bolivia, United States
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoBlockingRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WafApiProtectionMetric"
    sampled_requests_enabled   = true
  }
}


resource "aws_wafv2_web_acl_association" "waf_association" {
  resource_arn = "arn:aws:apigateway:${var.aws_region}::/restapis/${aws_api_gateway_rest_api.api.id}/stages/${aws_api_gateway_stage.prod.stage_name}"
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}