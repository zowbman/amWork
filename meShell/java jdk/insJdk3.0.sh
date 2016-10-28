#!/bin/bash
# shell script to install jdk
# example : source ./insJdk.sh jdk package
# version 3.0 
# created by zowbman@hotmail.com 2016/5/4 refer to http://www.tuicool.com/articles/f2M3YjF

# 1. remove openjdk if exists.
for i in $(rpm -qa | grep jdk | grep -v grep)
	do
		echo "Deleting rpm -> "$i
		rpm -e --nodeps $i
	done

if [[ ! -z $(rpm -qa | grep jdk | grep -v grep) ]];
	then 
	echo "-->Failed to remove the defult Jdk."
else 

# 2.tar -zxvf and install JDK
  	if [[ -z "$1" ]] ;
  		then 
  		echo "-->Failed to not found jdk package"
  	else
  		jdkPackage=$1
  		tempjdk=tempjdk
  		mkdir -p ./$tempjdk

  		chmod u+x ./$jdkPackage
		tar -zxvf $jdkPackage -C $tempjdk

		newjdk=$(find ./tempjdk -mindepth 1 -maxdepth 1 -exec basename {} \; | head -n 1)

		mkdir -p /usr/java
		mv ./$tempjdk/$newjdk /usr/java
		rm -rf ./$tempjdk

		rm -rf /usr/local/java
		ln -s /usr/java/$newjdk /usr/local/java

# 3. config /etc/bashrc
		today=$(date +%Y%m%d)

		cp /etc/bashrc /etc/profile.beforeAddJDKenv.$today.bak

		sed '/#JAVA ENV START/,/#JAVA ENV END/d' /etc/bashrc > /etc/bashrc.tmp

		\cp /etc/bashrc.tmp /etc/bashrc
		rm -f /etc/bashrc.tmp 

		echo "#JAVA ENV START" >> /etc/bashrc
		echo "JAVA_HOME=/usr/local/java" >> /etc/bashrc
		echo "CLASSPATH=.:\$JAVA_HOME/lib.tools.jar" >> /etc/bashrc
		echo "PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/bashrc
		echo "export JAVA_HOME CLASSPATH PATH" >> /etc/bashrc
		echo "#JAVA ENV END" >> /etc/bashrc

		#. /etc/profile

		source /etc/bashrc

		echo "-->JDK environment has been successed set in /etc/bashrc."

# 4. config user's .bash_profile
		#if [[  -z "$2" ]] ;
		#then 
		#echo "-->Config .bash_profile for JDK environment from $1"
		#username=$2
		#user_bash_file=/home/$username/.bash_profile

		#cp $user_bash_file user_bash_file.beforeAddJDKenv.$today.bak

		#cp /home/$username/.bash_profile /home/$username/.bash_profile.beforeAddJDKenv.$today.bak

		#sed '/#USER JAVA ENV START/,/#USER JAVA ENV END/d' /home/$username/.bash_profile

		#echo "#USER JAVA ENV START" >> $user_bash_file
		#echo "export JAVA_HOME=/usr/share/$newjdk" >> $user_bash_file
		#echo "export PATH=$JAVA_HOME/bin:$PATH" >> $user_bash_file
		#echo "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> $user_bash_file
		#echo "#USER JAVA ENV END" >> $user_bash_file

		#fi

# 5. Test JDK evironment
		if [[ -z $(ls /usr/java/$newjdk) ]];
		then
		echo "-->Failed to install JDK ($newjdk : /usr/java/$newjdk)"
		else 
		echo "-->JDK has been successed installed."
	    echo "java -version"
	    java -version
	    echo "javac -version"
	    javac -version
	    echo "ls \$JAVA_HOME"$JAVA_HOME
	    ls $JAVA_HOME
	  	fi
  	fi
fi