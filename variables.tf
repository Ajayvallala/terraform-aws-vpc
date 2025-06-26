variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "public_subnet_cidrs" {

}

variable "private_subnet_cidrs" {

}

variable "database_subnet_cidrs" {

}
variable "vpc_tags" {
  type    = map(string)
  default = {}
}

variable "igw_tags" {
  type    = map(string)
  default = {}
}

variable "public_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "private_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "database_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "eip_tags" {
  type    = map(string)
  default = {}
}
variable "nat_tags" {
  type    = map(string)
  default = {}
}
variable "public_route_tags" {
  type    = map(string)
  default = {}
}
variable "private_route_tags" {
  type    = map(string)
  default = {}
}
variable "database_route_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_peering_tags" {
  type    = map(string)
  default = {}
}

variable "is_peering_required" {
  default = false

}