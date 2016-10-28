# Gitlab

创建日期：2016/06/16

更新日期：2016/06/16

## 说明

心血来潮弄个gitlab，经过洗礼得出结论，网上都是骗人的

## 安装&配置

**版本信息**

系统版本：centos7

gitlab版本：GitLab CE

**gitlab安装**

安装按照官网教程进行安装:https://about.gitlab.com/downloads/

1. Install and configure the necessary dependencies

    sudo yum install curl policycoreutils openssh-server openssh-clients

    sudo systemctl enable sshd

    sudo systemctl start sshd

    sudo yum install postfix

    sudo systemctl enable postfix

    sudo systemctl start postfix

	//通常到达这一步就行了，因为装完centos7通常会已经关闭了防火墙//

    sudo firewall-cmd --permanent --add-service=http

    sudo systemctl reload firewalld

2. Add the GitLab package server and install the package

	curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
	
	sudo yum install gitlab-ce

3. Configure and start GitLab

	sudo gitlab-ctl reconfigure

到此gitlab安装完毕，打开浏览器输入http://{domain}|{ip}既可访问

注意：gitlab默认安装有集成nginx，并且nginx端口为80。如有已安装nginx的童鞋，并且想使用自己安装的nginx访问gitlab，请查看下面相关教程。

## gitlab相关指令（持续更新）

gitlab-ctl reconfigure 配置并启动GitLab，配置文件为gitlab.rb

gitlab-ctl start 启动服务

gitlab-ctl stop 停止服务

gitlab-ctl status 查看服务状态

gitlab-ctl cleanse 卸载服务

## 相关文件路径

gitlab.rb -> /etc/gitlab/gitlab.rb

gitlab其他配置文件 -> /var/opt/gitlab/xxx相关服务

gitlab日志 -> /var/log/gitlab/xxx相关服务



## 使用自己的nginx服务

参考文档：https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/nginx.md

里面有关于gitlab里的nginx相关配置，也有使用自己nginx服务的配置

**Using an existing Passenger/Nginx installation**

使用自己的nginx服务访问gitlab需要安装Passenger这个东西，但是通常我们安装自己nginx服务是不用安装Passenger，下面介绍两种安装Passenger的方式，参考资料：http://www.blogjava.net/pengpenglin/archive/2011/11/13/363643.html

方式一：通过手工配置和编译nginx，在下载nginx源码后进行编译时，添加以下参数

./configure-add-module=/path-to-passenger-root/ext/nginx

方式二：在已安装nginx服务前提下安装passenger（选用）

sudo passenger-install-nginx-module

跟着会出现几个问题让你回答：

1、一些说明（直接回车）

2、选用语言Which languages are you interested in?(这里选择Ruby)

3、给你选择1为下载nginx并配置（显然不是我们需要的），2为在原有的nginx进行安装（选择2，回车）

3、选择nginx源文件目录（就是./configure那个文件夹）

4、选择安装nginx的根目录（如果是源文件配置安装，则安装目录为/usr/local/nginx，输入完回车）

等待搞定。。这里他会弹出passenger_root xxx（还有一句忘了），下面会使用到


使用在你的nginx服务对应相关的配置文件中http模块内加如下代码

passenger_root /usr/local/lib/ruby/gems/2.3.0/gems/passenger-5.0.28;

后面跟的是passenger的根目录，如不知道可以执行passenger-conf --root 获取根目录

passenger安装配置完毕！

---

**Configuration**

在gitlab.rb配置文件中添加

\# Disable the built-in nginx

nginx['enable'] = false

\# Disable the built-in unicorn

unicorn['enable'] = false

\# Set the internal API URL

gitlab_rails['internal_api_url'] = 'http://yourdomain.com'

后执行sudo gitlab-ctl reconfigure 使配置生效

** Vhost(server block)**

在自己的nginx服务中配置文件添加：

	upstream gitlab-workhorse {
	  server unix://var/opt/gitlab/gitlab-workhorse/socket fail_timeout=0;
	}
	
	server {
	  listen *:80;
	  server_name git.example.com;
	  server_tokens off;
	  root /opt/gitlab/embedded/service/gitlab-rails/public;
	
	  client_max_body_size 250m;
	
	  access_log  /var/log/gitlab/nginx/gitlab_access.log;
	  error_log   /var/log/gitlab/nginx/gitlab_error.log;
	
	  # Ensure Passenger uses the bundled Ruby version
	  passenger_ruby /opt/gitlab/embedded/bin/ruby;
	
	  # Correct the $PATH variable to included packaged executables
	  passenger_env_var PATH "/opt/gitlab/bin:/opt/gitlab/embedded/bin:/usr/local/bin:/usr/bin:/bin";
	
	  # Make sure Passenger runs as the correct user and group to
	  # prevent permission issues
	  passenger_user git;
	  passenger_group git;
	
	  # Enable Passenger & keep at least one instance running at all times
	  passenger_enabled on;
	  passenger_min_instances 1;
	
	  location ~ ^/[\w\.-]+/[\w\.-]+/(info/refs|git-upload-pack|git-receive-pack)$ {
	    # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
	    error_page 418 = @gitlab-workhorse;
	    return 418;
	  }
	
	  location ~ ^/[\w\.-]+/[\w\.-]+/repository/archive {
	    # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
	    error_page 418 = @gitlab-workhorse;
	    return 418;
	  }
	
	  location ~ ^/api/v3/projects/.*/repository/archive {
	    # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
	    error_page 418 = @gitlab-workhorse;
	    return 418;
	  }
	
	  # Build artifacts should be submitted to this location
	  location ~ ^/[\w\.-]+/[\w\.-]+/builds/download {
	      client_max_body_size 0;
	      # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
	      error_page 418 = @gitlab-workhorse;
	      return 418;
	  }
	
	  # Build artifacts should be submitted to this location
	  location ~ /ci/api/v1/builds/[0-9]+/artifacts {
	      client_max_body_size 0;
	      # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
	      error_page 418 = @gitlab-workhorse;
	      return 418;
	  }
	
	  location @gitlab-workhorse {
	
	    ## https://github.com/gitlabhq/gitlabhq/issues/694
	    ## Some requests take more than 30 seconds.
	    proxy_read_timeout      3600;
	    proxy_connect_timeout   300;
	    proxy_redirect          off;
	
	    # Do not buffer Git HTTP responses
	    proxy_buffering off;
	
	    proxy_set_header    Host                $http_host;
	    proxy_set_header    X-Real-IP           $remote_addr;
	    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
	    proxy_set_header    X-Forwarded-Proto   $scheme;
	
	    proxy_pass http://gitlab-workhorse;
	
	    ## The following settings only work with NGINX 1.7.11 or newer
	    #
	    ## Pass chunked request bodies to gitlab-workhorse as-is
	    # proxy_request_buffering off;
	    # proxy_http_version 1.1;
	  }
	
	  ## Enable gzip compression as per rails guide:
	  ## http://guides.rubyonrails.org/asset_pipeline.html#gzip-compression
	  ## WARNING: If you are using relative urls remove the block below
	  ## See config/application.rb under "Relative url support" for the list of
	  ## other files that need to be changed for relative url support
	  location ~ ^/(assets)/ {
	    root /opt/gitlab/embedded/service/gitlab-rails/public;
	    gzip_static on; # to serve pre-gzipped version
	    expires max;
	    add_header Cache-Control public;
	  }
	
	  error_page 502 /502.html;
	}

其中修改server_name为你的ip或者域名即可

重启nginx服务。。。

打开浏览器访问http://{IP}|{domain}既可访问gitlab

**不要开心太早**

你会发现，浏览器访问，样式木有了怎么办，在网上找了很多资料，用执行语句重新生成css文件和js文件，那些都不知道什么版本gitlab了，不可取。

发现问题：正常引用无法渲染，说引用css文件的mime格式问题,定位nginx

解决方法，查找gitlab集成nginx服务配置文件与自己nginx配置文件进行对比，gitlab集成的nginx服务目录在/vat/opt/gitlab/nginx,发现以下一句话

include /opt/gitlab/embedded/conf/mime.type;

ok，重启nginx服务，清空浏览器缓存，刷新，搞定

**不要开心太早2（如是有自己dns域名服务器与nginx配合，并且gitlab于dns域名服务器同一台机子上）**

这个情况应该属于个人情况，dns域名服务与gitlab服务在一台机子上

在gitlab，push/pull的时候发生问题，查看gitlab-shell日志文件，发现接口连不上302（已验证），no kown hostname（已验证）问题

发现问题：使用gitlab进行仓库push/pull时候发生问题，在调用gitlabapi接口出现302、no kown hostname问题

解决问题（想了很久）：访问gitlabapi时候，是使用域名访问，http://{domain}/xxx/xxx为什么会不行。我在服务机上试了一下，ping我配的域名，居然不通。但是请求时重客户端发出，除非这个api访问时服务端自己发出的，带着这个大胆的想法配置了服务机上的host文件，将本机ip与gitlab配的域名绑定，居然可以了~~~，得出这个api请求时由服务端自己发出，解决方案有以下两点

1、配置服务机的dns地址为服务机的dns

2、配置服务机的host文件，本机ip与gitlab域名进行绑定

完美。。。

## gitlab头像问题














