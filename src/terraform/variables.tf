variable "project" {
  type    = string
  default = "star-wars-etl"
}

variable "tags" {
  type = map(any)
  default = {
    "Project" = "star-wars-etl"
    "Owner"   = "Guilherme Gandolfi"
  }
}

variable "env" {

}

variable "enviorment" {
  type = map(any)
  default = {
    "dev"  = "dev"
    "prod" = "prod"
  }
}