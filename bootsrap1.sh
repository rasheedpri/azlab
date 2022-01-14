export fgt=20.81.20.91
user=admin
pwd=admin
  echo "============================"
  echo "Bootstraping FortiGate"
  echo "============================"
  {
  echo $pwd;
  echo $pwd;
  echo "config system interface";
  echo "edit port1";
  echo "set allowaccess https http ssh ping";
  echo "next"
  echo "edit port2";
  echo "set mode dhcp"
  echo "set allowaccess ssh ping";
  echo "end";
  echo "config system global";
  echo "set admin-port 8080";
  echo "end"
  echo "exit"
 } | ssh -o StrictHostKeyChecking=no admin@$fgt
