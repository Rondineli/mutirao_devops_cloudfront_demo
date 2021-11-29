locals {                                                            
  subnet_ids_string = join(",", data.aws_subnet_ids.subnet_ids.ids)
  subnet_ids_list   = split(",", local.subnet_ids_string)
  aliases           = split(",", var.aliases)
}