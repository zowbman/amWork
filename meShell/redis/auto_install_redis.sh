#!/bin/bash
#Author:zowbman
#Descr:auto_install_redis.sh
#Date:2016/06/23

redisPackage=$1

if [[ -z "$1" ]];
	then
	echo "--Failed to not found redis package"
else
#redis
	tar -zxvf $redisPackage
	redisPackage=$(basename $redisPackage .tar.gz)
	mv $redisPackage /usr/local/

	redisHome=/usr/local/$redisPackage
	cd $redisHome
	make 
	make install

	###mkdir redis folder
	mkdir -p /usr/local/redis/bin
	mkdir -p /usr/local/redis/etc

	cp src/redis-benchmark /usr/local/redis/bin/
	cp src/redis-check-aof /usr/local/redis/bin/
	#redis3.2 not found file
	#cp src/redis-check-dump /usr/local/redis/bin/
	cp src/redis-sentinel /usr/local/redis/bin/
	cp src/redis-server /usr/local/redis/bin/
	cp src/redis-trib.rb /usr/local/redis/bin/
	cp redis.conf /usr/local/redis/etc/

	#redis start
	#$redisHome/bin/redis-server $redisHome/etc/redis.conf &
fi