#!/bin/bash
# shell script to install jdk (default version jdk-6u45-linux-x64.bin)
# example : ./insJdk.sh  or ./insJdk.sh username
# version 1.0 
# created by zowbman@hotmail.com 2016/5/4 clone from http://www.tuicool.com/articles/f2M3YjF

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

  # 2.unzip and install JDK(jdk-6u45-linux-x64.bin)

  chmod u+x ./jdk-6u45-linux-x64.bin
  ./jdk-6u45-linux-x64.bin

  mkdir /usr/java
  mv ./jdk1.6.0_45 /usr/java/jdk1.6.0_45
  rm -rf ./jdk1.6.0_45
  
  


  # 3. config /etc/profile

  cp /etc/profile /etc/profile.beforeAddJDKenv.20140507.bak

  echo "JAVA_HOME=/usr/java/jdk1.6.0_45" >> /etc/profile
  echo "CLASSPATH=.:$JAVA_HOME/lib.tools.jar" >> /etc/profile
  echo "PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile
  echo "export JAVA_HOME CLASSPATH PATH" >> /etc/profileo 
  echo "CLASSPATH=.:$JAVA_HOME/lib.tools.jar" >> /etc/profile
  echo "PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile
  echo "export JAVA_HOME CLASSPATH PATH" >> /etc/profile

  
  #echo "-->JDK environment has been successed set in /etc/profile."

  # 4. config user's .bash_profile
  if [[  -z "$1" ]] ;
  then 
    #echo "-->Config .bash_profile for JDK environment from $1"
    username=$1
    user_bash_file=/home/$username/.bash_profile
    
    #cp $user_bash_file user_bash_file.beforeAddJDKenv.20140507.bak

    cp /home/$username/.bash_profile /home/$username/.bash_profile.beforeAddJDKenv.20140507.bak

    echo "export JAVA_HOME=/usr/share/jdk1.6.0_20" >> $user_bash_file
    echo "export PATH=$JAVA_HOME/bin:$PATH" >> $user_bash_file
    echo "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> $user_bash_file

  fi

  # 5. Test JDK evironment
  if [[ ! -z $(ls /user/java/jdk1.6.0_45) ]];
  then
    echo "-->Failed to install JDK (jdk-6u45-linux-x64 : /usr/java/jdk1.6.0_45)"
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