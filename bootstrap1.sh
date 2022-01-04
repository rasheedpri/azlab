export fgt=20.75.156.227
user=admin
pwd=admin
  echo "============================"
  echo "Bootstraping Fortigate"
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
  echo "end";
  echo "config system global";
  echo "set admin-port 8080";
  echo "end"
  echo "exit"
 } | ssh -o StrictHostKeyChecking=no admin@$fgt
