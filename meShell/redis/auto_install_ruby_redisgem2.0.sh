#!/bin/bash
#Author:zowbman
#Descr:auto_install_ruby_redisgem
#Date:2016/06/23

# before centos6
# yum install -y zlib-*
# yum install -y zlib.i686
# yum install -y zlib-devel.i686

# touch zlib.txt
# echo `rpm -qa | grep zlib-1* || zlib-devel*` > zlib.txt

rubyPackage=$1
redisgemsPackage=$2

if [[ ${rubyPackage/"ruby"//} == $rubyPackage ]] ;
	then
	rubyPackage=0
	echo "-->Failed to not found ruby package"
fi

if [[ ${redisgemsPackage/"redis"//} == $redisgemsPackage ]] ;
	then
	redisgemsPackage=0
	echo "-->Failed to not found redisgems package"
fi

# ruby:
if [[ $rubyPackage != 0 ]] ; 
	then
	tar -zxvf $rubyPackage
	rubyPackage=$(basename $rubyPackage .tar.gz)
	cd $rubyPackage
	#./configure
	#make & make install
	cd ..

fi

# redisgems:
if [[ $redisgemsPackage != 0 ]] ; 
	then
	unzip $redisgemsPackage
	redisgemsPackage=$(basename $redisgemsPackage .zip)".gem"
	echo $redisgemsPackage
	#gem install -l $redisgemsPackage
fi