# 共通
variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "tags" {
  description = "共通タグ"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "リソース命名のプレフィックス"
  type        = string
}

# VPC
variable "vpc_cidr" {
  description = "VPC の CIDR (例: 10.0.0.0/16)"
  type        = string
}

# subnet
variable "azs" {
  description = "使うAZを指定（例: ['ap-northeast-1a','ap-northeast-1c']）"
  type        = list(string)
}
variable "public_subnet_cidrs" {
  description = "パブリックサブネットのサイダーを指定（例: ['10.0.1.0/24','10.0.2.0/24']）"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "パブリックサブネットのサイダーを指定（例: ['10.0.101.0/24','10.0.102.0/24']）"
  type = list(string)
}