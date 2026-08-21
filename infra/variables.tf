variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Região da AWS onde os recursos serão criados"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Ambiente de execução"
}

variable "rate_limit" {
  type        = number
  default     = 100
  description = "Limite de requisições por IP a cada 5 minutos"
}