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

# aurora
variable "db_name" {
  description = "DB名"
  type        = string
}

variable "db_username" {
  description = "DBのユーザー名"
  type        = string
}

variable "db_password" {
  description = "DBのパスワード"
  type        = string
}

# ecs
variable "container_port" {
  description = "ecsのポート"
  type        = number
  default     = 3000
}
