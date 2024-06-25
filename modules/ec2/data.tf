data "template_file" "user_data_linux" {
  template = "${file("${path.module}/user_data/zabbix-agent-linux.txt")}"
  vars = {
    hostname = "${var.instance.name}"
    account = "${var.account}"
  }
}

data "template_file" "user_data_windows" {
  template = "${file("${path.module}/user_data/zabbix-agent-windows.txt")}"
   vars = {
    hostname = "${var.instance.name}"
    account = "${var.account}"
  }
}



