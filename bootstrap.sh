export fgt=20.127.131.252
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
  echo "end";
  echo "exit"
 } | ssh -o StrictHostKeyChecking=no admin@$fgt
