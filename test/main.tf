
resource "local_file" "bootstrap2" {
    count       = "2"
    content     =  templatefile("${path.cwd}/hosts.tftpl",  { ip = "${element(var.pip, count.index)}" })
    filename    = "${path.cwd}/hosts${count.index + 1}.sh"
}






variable "pip"    {
    default = ["10.10.0.1/16", "10.10.0.2/16"]
}

