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
