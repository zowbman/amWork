#Nexus搭建Maven私服（Windows版）

创建日期：2016/05/09

更新日期：2016/05/12

##注意

nexus3.0需JDK1.8

nexus2.0需JDK1.7

##Nexu3.0搭建

###Nexu下载地址

```
URL:http://www.sonatype.org/nexus/go
```

安装步骤：

```
步骤一：解压nexus压缩包
```

```
步骤二：运行cmd，进入nexus根目录中bin，运行nexus.exe /run命令（注意要加/）
```

```
步骤三：访问http://localhost:8081，进入nexus
```

```
步骤四：登陆nexus，账号/密码：admin/admin123
```

##Nexu3.0介绍
###Nexus的仓库分为：

```
hosted 宿主仓库：主要用于部署无法从公共仓库获取的构建（如orcale的JDBC驱动）以及自己或第三方的项目构建；
```

```
proxy代理仓库：代理公共的远程仓库；
```

```
virtual虚拟仓库：用于适配Maven1；
```

```
group仓库组：Nexus通过仓库组的概念统一管理多个仓库，这样我们在项目中直接请求仓库组即可请求道仓库组管理的多个仓库；
```

---

##Nexus2.0搭建

###Nexus下载地址

```
URL:http://www.sonatype.org/nexus/go
```

安装步骤：

```
步骤一：解压nexus压缩包
```

```
步骤二：运行cmd，进入nexus根目录中bin，运行nexus install命令，加入window服务，以后直接运行nexus start/stop/restart 即可启动/停止/重启nexus
```

```
步骤三：访问http://localhost:8081，进入nexus
```

```
步骤四：登陆nexus，账号/密码：admin/admin123
```

###Nexus修改端口

```在nexus根目录的conf中的nexus.properties中的application-port修改端口（默认为8081）```

###Nexus手动更新maven 索引

步骤1：

下载以下：

```http://repo1.maven.org/maven2/.index/nexus-maven-repository-index.gz```

```http://repo1.maven.org/maven2/.index/nexus-maven-repository-index.properties```

```indexer-cli-5.1.1.jar(版本随意)```

把三个文件存放在一个文件夹当中,管理员运行cmd,输入以下代码：

```java -jar indexer-cli-5.1.1.jar -u nexus-maven-repository-index.gz -d indexer```

之后在三个文件所在的文件夹中出现一个indexer的文件夹,里面就是我们所需要的索引文件。

步骤2：

把indexer里的文件全部复制至nexus所在路径（非nexus目录中），有一个名为/sonatype-work/nexus/indexer/central-ctx（默认与nexus同级目录），并先把里面的东西全部清除（如出现了文件正在被占用，就停nexus后再删除）。

步骤3：

重启nexus，登陆nexus，就发现索引更新完毕。

##心得

在网上看了非常多关于nexus的帖子，大部分都仅仅介绍如何安装以及配置，但是留下了一些问题给我

这里是对于nexus进行一些心得记录（因nexus3.0中文文档缺少，本人英文不可以，其实跟nexus2.0核心的东西差不多）

1、在nexus2.0中，启动后，浏览器访问的私服仓库索引，只有构建过的，并非全部索引，如开发人员所需是nexus中并没有的，则转向maven中央库中进行访问下载，其他开发人员如是同样需求，则访问nexus私服就可以进行构建。





