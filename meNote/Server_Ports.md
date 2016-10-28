# 服务端口说明文档

创建日期：2016/05/27

更新日期：2016/06/24

## 说明（计算机端口分类）

第一类：

公认端口（Well Known Ports）：0~1023

第二类：

注册端口（Registered Ports）:1024~49151

第三类：

动态/或私有端口（Dynamic and/or Private Ports）：49152~65535

## 服务端口说明文档

**固定端口**

|端口号		|服务
|---		|---
|80			|nginx
|8080~9090	|项目服务端口
|10000~20000|服务端口

## 服务列表

|服务		|端口号	|服务名 					|访问地址										|说明
|---		|---	|---					|---											|---
|nginx		|80		|nginx.service			|http://nginx.zowbman.net、http://zowbman.net	|nginx服务器
|nexus3.0	|10000	|nexus.service			|http://nexus.zowbman.net						|nexus服务器
|gitlab		|		|gitlab-ctl start		|http://gitlab.zowbman.net						|gitlab仓库
|redmine	|10001	|						|http://redmine.zowbman.net						|redmine
|dns		|		|named-chroot.service	|---												|dns域名服务器

