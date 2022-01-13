data "template_file" "test" {
  template = "${file("${path.cwd}/test.sh")}"
  vars = {
    ipaddress   = "${var.ip}"
  }
}




resource "local_file" "bootstrap" {
 filename = "${path.cwd}/bootstrap.sh"
 content = data.template_file.test.rendered
}

resource "local_file" "bootstrap2" {
    content     =  templatefile("${path.cwd}/hosts.tftpl",  { ip = "${var.pip}", vm ="AZUVNLABFGT00" } )
    filename    = "${path.cwd}/hosts.sh"
}


# data "template_file" "test2" {
#   template = "${file("${path.cwd}/hosts.tftpl")}"
#   vars = {
#     ip   = "${var.pip}"
#     vm   = "${var.vm}"

#   }
# }


variable "ip" {
    default = "10.10.0.1"
}


variable "pip"    {
    default = ["10.10.0.1/16", "10.10.0.2/16"]
}

variable "vm"    {
    default = ["FGT01", "FGT02"]
}

