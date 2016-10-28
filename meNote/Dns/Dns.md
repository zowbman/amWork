# Dns域名服务器

创建日期：2016/06/09

更改日期：2016/06/09

## 说明

BIND（Berkeley internet Name Daemon)也叫做NAMED

这里将BIND的运行根目录改为/var/named/chroot/，对于BIND来说，这个目录就是/（根目录）。

"jail"(监牢)是一个软件机制，其功能是使得某个程序无法访问规定域名之外的资源，同样也为了增强安全性（LCTT 译注：chroot “监牢”，所谓“监牢”就是指通过chroot机制来更改某个进程所能看到的根目录，即将某进程限制在指定目录中，保证该进程只能对该目录及其子目录的文件进行操作，从而保证整个服务器的安全）。BIND Chroot DNS 服务器的默认"监牢"为/var/named/chroot。

## 搭建
 
系统环境：centos7

**1、安装Bind Chroot DNS 服务器**

``
sudo yum install bind-chroot bind -y
``

**2、拷贝bind相关文件，准备bind chroot 环境**

``
sudo cp -R /usr/share/doc/bind-*/sample/var/named/* /var/named/chroot/var/named/
``

**3、在bind chroot的目录中创建相关文件**

``
sudo touch /var/named/chroot/var/named/data/cache_dump.db
``

``
sudo touch /var/named/chroot/var/named/data/named_stats.txt
``

``
sudo touch /var/named/chroot/var/named/data/named_mem_stats.txt
``

``
sudo touch /var/named/chroot/var/named/data/named.run
``

``
sudo mkdir /var/named/chroot/var/named/dynamic
``

``
touch /var/named/chroot/var/named/dynamic/managed-keys.bind
``

**4、将Bind锁定文件设置为可写**

``
sudo chmod -R 777 /var/named/chroot/var/named/data
``

``
sudo chmod -R 777 /var/named/chroot/var/named/dynamic
``

**5、将/etc/named.conf拷贝到bind chroot目录**

``
sudo cp -p /etc/named.conf /var/named/chroot/etc/named.conf
``

**6、在/etc/named.conf中对bind进行配置**

在 named.conf 文件尾添加 example.local 域信息， 创建转发域（Forward Zone）与反向域（Reverse Zone）（LCTT 译注：这里example.local 并非一个真实有效的互联网域名，而是通常用于本地测试的一个域名；如果你需要做权威 DNS 解析，你可以将你拥有的域名如这里所示配置解析。）：

``
sudo vi /var/named/chroot/etc/named.conf
``

---
	..
	..
	zone "zowbman.net" {
	    type master;
	    file "zowbman.net.zone";
	};
	 
	zone "1.168.192.in-addr.arpa" IN {
	        type master;
	        file "192.168.1.zone";
	};
	..
	..

named.conf 完全配置如下：

	//
	// named.conf
	//
	// 由Red Hat提供，将 ISC BIND named(8) DNS服务器 
	// 配置为暂存域名服务器 (用来做本地DNS解析).
	//
	// See /usr/share/doc/bind*/sample/ for example named configuration files.
	//
	 
	options {
	        listen-on port 53 { any; };
			// 如ipv6有问题可注释
	        listen-on-v6 port 53 { ::1; };
	        directory       "/var/named";
	        dump-file       "/var/named/data/cache_dump.db";
	        statistics-file "/var/named/data/named_stats.txt";
	        memstatistics-file "/var/named/data/named_mem_stats.txt";
	        allow-query     { any; };
	 
	        /*
	         - 如果你要建立一个 授权域名服务器 服务器, 那么不要开启 recursion（递归） 功能。
	         - 如果你要建立一个 递归 DNS 服务器, 那么需要开启recursion 功能。
	         - 如果你的递归DNS服务器有公网IP地址, 你必须开启访问控制功能，
	           只有那些合法用户才可以发询问. 如果不这么做的话，那么你的服
	           服务就会受到DNS 放大攻击。实现BCP38将有效抵御这类攻击。
	        */
	        recursion yes;
			//下面设置dns转发器（外网dns）
			forwarders {211.136.192.6; 120.196.165.24;};
			// 下面不注释有本地解析
			// forward only ;
	 		
			//下面会进行解析后安全检测（关闭）
	        dnssec-enable no;
	        dnssec-validation no;
	        // dnssec-lookaside auto;
	 
	        /* Path to ISC DLV key */
	        bindkeys-file "/etc/named.iscdlv.key";
	 
	        managed-keys-directory "/var/named/dynamic";
	 
	        pid-file "/run/named/named.pid";
	        session-keyfile "/run/named/session.key";
	};
	 
	logging {
	        channel default_debug {
	                file "data/named.run";
	                severity dynamic;
	        };
	};
	 
	zone "." IN {
	        type hint;
	        file "named.ca";
	};
	 
	zone "zowbman.net" {
	    type master;
	    file "zowbman.net.zone";
	};
	 
	zone "1.168.192.in-addr.arpa" IN {
	        type master;
	        file "192.168.1.zone";
	};
	 
	include "/etc/named.rfc1912.zones";
	include "/etc/named.root.key";

**7、为exampl.local域名撞见转发域与反向域文件**

a)创建转发域

``
sudo vi /var/named/chroot/var/named/zowbman.net.zone
``

	添加如下内容并保存
	
	;
	;       Addresses and other host information.
	;
	$TTL 86400
	@       IN      SOA     zowbman.net. hostmaster.zowbman.net. (
	                               2014101901      ; Serial
	                               43200      ; Refresh
	                               3600       ; Retry
	                               3600000    ; Expire
	                               2592000 )  ; Minimum
	
	;       Define the nameservers and the mail servers
	
	               IN      NS      nexus.zowbman.net.
	               IN      NS      nginx.zowbman.net.
	
	                 IN      A       192.168.1.115
	nexus            IN      A       192.168.1.115
	nginx            IN      A       192.168.1.115

b)创建反向域

``
sudo vi /var/named/chroot/var/named/192.168.1.zone
``

	;
	;       Addresses and other host information.
	;
	$TTL 86400
	@       IN      SOA     zowbman.net. hostmaster.zowbman.net. (
	                               2014101901      ; Serial
	                               43200      ; Refresh
	                               3600       ; Retry
	                               3600000    ; Expire
	                               2592000 )  ; Minimum
	
	1.168.192.in-addr.arpa. IN      NS      zowbman.net.
	
	115.1.168.192.in-addr.arpa. IN PTR nexus.zowbman.net.
	115.1.168.192.in-addr.arpa. IN PTR nginx.zowbman.net.


**8、开机自启动 bind-chroot服务**

``
sudo /usr/libexec/setup-named-chroot.sh /var/named/chroot on
``

``
systemctl stop named
``

``
systemctl disable named
``

到下面一步可能会出现问题，原因是selinux安全级别的问题。

``
systemctl start named-chroot
``

``
systemctl enable named-chroot
``