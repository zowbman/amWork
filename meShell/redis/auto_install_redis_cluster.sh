#!/bin/bash
#Author:zowbman
#Descr:auto_install_redis_cluster
#Date:2016/06/24r
#sh xxx.sh {IP} [port1 port2 ...]

checknic(){
          IPLIST=`ifconfig | grep netmask | cut -d : -f2 | awk '{print $2}' `
          tag=0
          for i in `echo $IPLIST`
          do
                if [ "$i" = "$1" ];
                then tag=1;break;
                fi
          done
          echo "$tag"
          if [ $tag == 1 ]
          then
                INIP=$1
          else
                echo "Sorry,your machine doesn't have an inner ip address.Please check your ip parameter's truth."
                exit 1          
          fi
}

checknic $1

###mkdir redis folder default:/data1/cluster/
mkdir -p /usr/local/redis/cluster/6379/data
mkdir -p /usr/local/redis/cluster/6379/log

###addgroup && adduser redis
/usr/sbin/groupadd redis
/usr/sbin/useradd -g redis redis

###add redis_parameter
cat>>/usr/local/redis/etc/6379.conf<<MUL
maxmemory-policy allkeys-lru
rename-command CONFIG zowbman#`< /dev/urandom tr -dc _@A-Za-z0-9 | head -c32 `
rename-command FLUSHDB ""
rename-command FLUSHALL ""
MUL

###set system_parameter
cat>>/etc/rc.local<<'MUL'
su - redis -c "/usr/local/redis/bin/redis-server  /usr/local/redis/etc/6379.conf"
MUL
echo $checknic

sed -i "s/\(127.0.0.1\)/$INIP \1/g" /usr/local/redis/etc/6379.conf

chown redis:redis -R /usr/local/redis          
#default :/data1/redis                                                                                                                                          
#chown redis:redis -R /data1/redis

cd /usr/local/redis/etc/
paranum=$#
if [[ $paranum -ge 1 ]]
then
        arr=($*)
        for((i=0;i<$paranum;i++))
        do
                if [[ ${arr[$i]} =~ ^[0-9]*$ ]]
                then
                        if [[ ${arr[$i]} -gt 0 && ${arr[$i]} -lt 65535 && ${arr[$i]} -ne 6379 ]]
                        then
                                cp 6379.conf ${arr[$i]}.conf
                                #change port
                                sed -i "s/6379/${arr[$i]}/g" ${arr[$i]}.conf
                                #default:/data1/redis/
                                mkdir  -p /usr/local/redis/cluster/${arr[$i]}/log
                                mkdir  -p /usr/local/redis/cluster/${arr[$i]}/data
                                #start
                                su - redis -c "/usr/local/redis/bin/redis-server  /usr/local/redis/etc/${arr[$i]}.conf &"
                                cat>>/etc/rc.local<<MUL
                                su - redis -c "/usr/local/redis/bin/redis-server  /usr/local/redis/etc/${arr[$i]}.conf"
MUL
                        fi
                fi
        done
fi

#chckredisprocess
cd ../bin/
cat >>simple_check_redis.sh<<"NULL"
#!/bin/bash
WAY=/usr/local/redis/
LOG=$WAY/checkredis.log.`date +"%Y%m%d"`
cd $WAY >/dev/null 2>&1|| mkdir -p $WAY

declare -a rcredis
rcredis=(`grep redis-server /etc/rc.local|grep -v "^#"`)
count=${#rcredis[*]}
i=0
while [[ $i -lt $count ]]
do
        port=${rcredis[$((i+1))]}
        port=${port##?*/}
        port=${port%%.*?}
        if [[ `ps -ef | grep redis-server |grep $port|wc -l` -eq 0 ]]
        then
                echo "Note that redis-server at $port port do not exist.now try to restart it.">>$LOG
                ${rcredis[$i]} ${rcredis[$((i+1))]} >>$LOG 2>&1
                if [[ $? -eq 1 ]]
                then
                        echo "${rcredis[$i]} ${rcredis[$((i+1))]}  restart at `date +"%Y%m%d"` fail.">>$LOG
                fi
        fi
        i=$((i+2))
done
NULL
echo "* * * * * (cd /usr/local/redis/bin/ && /bin/sh simple_check_redis.sh >> /dev/null 2>&1)" >>/var/spool/cron/root

chown redis:redis -R /usr/local/redis
#default:/data1/redis
#chown redis:redis -R /data1/redis


su - redis -c "/usr/local/redis/bin/redis-server  /usr/local/redis/etc/6379.conf &"

rm -f /data1/$scriptName.Lockfile
ps -ef |grep redis
#cp /usr/local/redis/bin/redis-cli /usr/local/bin/
exit 0