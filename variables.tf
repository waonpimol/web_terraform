variable "aws_region" {
  description = "Region ของ AWS"
  type        = string
  default     = "ap-southeast-1"
}

variable "key_name" {
  description = "ชื่อ Key Pair"
  type        = string
  default     = "my-terraform-key-5"
}

variable "instance_type" {
  description = "ขนาด EC2"
  type        = string
  default     = "t3.micro"
}