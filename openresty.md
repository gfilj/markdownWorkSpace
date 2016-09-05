###openrestry


什么是openresty（nginx+lua）现在结合了varnish 前段架构很强悍啊
通过lua调用nginx的函数，
 content_by_lua 和 content_by_lua_file nginx.conf 嵌入lua文件调用nginx函数

 content_by_lua 一般在很简单的lua脚本时使用
 
 cotent_by_lua_file 适应于复杂的 lua 脚本，专门放入一个文件中：路径相对于 /opt/openresty/nginx
 
  在 nginx.conf 文件的 server {.. ...} 中加入 lua_code_cache off 可以方便调试lua脚本，修改lua脚本之后，不需要 reload nginx
  
  http://www.codesec.net/view/198476.html
  
  http://blog.csdn.net/ruiyiin/article/details/38355667
  
  http://zhidao.baidu.com/link?url=nDkEy6pUCALBeFXYnQgy-h0PuuuhBP2Y5w-lELi2U1cCi7EzuOcWY1dICwFBIZis3Q2ZWpkZbcCnJ4WVMfY8YvUEaQ4HHw_DfyxyvxabyYG




<pre><code>
user  appops netease;
worker_processes  1;

#error_log  logs/error.log info;
#error_log  logs/error.log  notice;
error_log  /dev/null;

#pid        logs/nginx.pid;


events {
    worker_connections  65535;
    use epoll;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format main '[$time_local] ; $remote_addr ;"$http_x_forwarded_for" ; $status ; $body_bytes_sent ; http://$host$request_uri ; $http_referer ; $content_length ; "$request_body" ; $upstream_addr ; $upstream_status; $upstream_response_time; $request_time; $upstream_cache_status;$http_user_agent';

    log_format cache '[$time_local] ; $remote_addr ; "$http_x_forwarded_for" ; $status ; $body_bytes_sent ; http://$host$request_uri ; $http_referer ; $upstream_addr ; $upstream_status; $request_time; $upstream_response_time; $content_length ; $upstream_cache_status; "$http_user_agent" ; ';


    access_log  /dev/null;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    lua_package_path '$prefix/conf/?.lua;;';

    #gzip  on;
    proxy_temp_path /run/shm/scimg_cache_temp;
    proxy_cache_path /run/shm/scimg_cache levels=1:2 keys_zone=scimg_cache:32m inactive=12h max_size=1G;

    proxy_intercept_errors on;

    upstream s.cimg.163.com {
        server 10.102.135.127:8080;
    }

    server {
        listen       8080;
        server_name  monitor.cimg.163.com;
        log_not_found off;

        access_log /dev/null;

        location ~ ^/(i|e|pi|pe)/ {
            proxy_pass http://127.0.0.1:8181;
            proxy_set_header Host s.cimg.163.com;
        }
        location / {
            empty_gif;
            expires 120;
        }
    }
    server {
        listen       8080 backlog=818192;
        server_name  s.cimg.163.com;
        server_name  simg.cache.netease.com;
        log_not_found off;

        access_log logs/s.cimg.163.com.8080-access.log main;

        location ~ ^/(i|e|pi|pe)/ {
            expires 1y;
            proxy_cache scimg_cache;
            proxy_cache_key $scheme$request_uri;
            proxy_cache_valid 200 304 30d;
            proxy_cache_valid 500 403 404 30s;
            proxy_pass http://127.0.0.1:8181;
            proxy_set_header Host s.cimg.163.com;
            add_header Last-Modified  "Thu, 01 Dec 2015 00:00:00 GMT";
        }
        location / {
            expires 1d;
            rewrite "^/(.*)\.([0-9]+)x([0-9]+)\.jpg$" /i/cimg2.163.com/$1.$2x$3.jpg last;
            rewrite "^/(.*)\.([0-9]+)x([0-9]+)\.jpg[_\.]f$" /i/cimg2.163.com/$1.$2x$3.jpg.f last;
        }

       location /favicon.ico {
           return 200;
           expires 1y;
        }

        location ~ ^/purge(/.*) {
            allow 127.0.0.1;
            allow 192.168.0.0/16;
            allow 10.100.20.0/23;
            proxy_cache_purge scimg_cache $scheme$1;
        }

        location ~ ^/purgeall(/.*) {
            allow 127.0.0.1;
            allow 192.168.0.0/16;
            allow 10.100.20.0/23;
            set $imageurl $1;
            content_by_lua '
              local cmd = "/usr/bin/find /run/shm/scimg_cache  -type f | xargs grep \'"..ngx.var.imageurl.."\' |awk ".."\'{print $3}\'".."|while read line;do echo $line|xargs head -n 2|tail -n 1|awk -F[:] \'{print $2}\' |sed \'s/ http//\';done";
              local handle = io.popen(cmd);
              for url in handle:lines() do
                ngx.location.capture("/purge"..url);
              end
              handle:close();
            ';
        }
    }
    server {
        listen       8181;
        server_name  s.cimg.163.com;
        log_not_found off;

        access_log logs/s.cimg.163.com.8181-access.log main;

        location ~ ^/i/+(.*)\.([0-9]+x[0-9]+)(\.[0-9]+)?(\.auto)?\.gif {
            set $u $1;
            set $size $2;
            set $qua $3;
            content_by_lua '
              local magick = require "magick";
              local res = ngx.location.capture("/s/"..ngx.var.u);
              if res.status == 302 then
                 local reurl, n = ngx.re.sub(res.header["Location"], "http://(.*)", "$1");
                 res = ngx.location.capture("/s/"..reurl);
              end
              if res.status == ngx.HTTP_OK and ngx.re.match(res.header["Content-Type"],"image","io") then
                  local img = magick.load_image_from_blob(res.body);
                  if img then
                      if ngx.var.qua ~= "" then
                          local imgqua, n = ngx.re.sub(ngx.var.qua, ".([0-9]+)$", "$1");
                          img:set_quality(tonumber(imgqua));
                      else
                          img:set_quality(tonumber(85));
                      end
                      ngx.header.content_type = res.header["Content-Type"];
                      local ret = magick.gifThumb(img,ngx.var.size);
                      if(ret ~= nil) then
                           ngx.say(ret);
                      else
                           ngx.exit(res.status);
                      end
                 end
              else
                  ngx.exit(res.status);
              end
            ';
        }
        location ~ ^/i/+(.*)\.([0-9]+x[0-9]+)(\.[0-9]+)?(\.auto)?\.jpg { 
            set $u $1;
            set $size $2;
            set $qua $3;
            content_by_lua '
              local magick = require "magick";
              local res = ngx.location.capture("/s/"..ngx.var.u);
              if res.status == 302 then
                 local reurl, n = ngx.re.sub(res.header["Location"], "http://(.*)", "$1");
                 res = ngx.location.capture("/s/"..reurl);
              end
              if res.status == ngx.HTTP_OK and ngx.re.match(res.header["Content-Type"],"image","io") then
                  local img = magick.load_image_from_blob(res.body);
                  if img then
                      if ngx.var.qua ~= "" then
                          local imgqua, n = ngx.re.sub(ngx.var.qua, ".([0-9]+)$", "$1");
                          img:set_quality(tonumber(imgqua));
                      else
                          img:set_quality(tonumber(85));
                      end
                      if img:get_format() == "png" then
                        local depth = tonumber(img:get_depth());
                        if not ( depth == 8 or depth == 16 ) then
                          img:set_format("jpg");
                        end
                        local type = img:get_imagetype();
                        if not ( type == 3 or type == 5 or type == 7 or type == 9 ) then
                          img:set_format("jpg");
                        end
                      end
                      ngx.header.content_type = res.header["Content-Type"];
                      ngx.say(magick.thumb(img,ngx.var.size));
                  end
              else
                  ngx.exit(res.status);
              end
            ';
        }
        location ~ ^/e/+(.*)\.([0-9]+)x([0-9]+)(\.[0-9]+)?(\.auto)?\.jpg { 
            set $u $1;
            set $x $2;
            set $y $3;
            set $qua $4;
            content_by_lua '
              local dx = tonumber(ngx.var.x)
              local dy = tonumber(ngx.var.y)
              if dx ~= dy then
                ngx.say("width not eq height!")
              else
                local magick = require "magick";
                local res = ngx.location.capture("/s/"..ngx.var.u);
                if res.status == 302 then
                   local reurl, n = ngx.re.sub(res.header["Location"], "http://(.*)", "$1");
                   res = ngx.location.capture("/s/"..reurl);
                end
                if res.status == ngx.HTTP_OK and ngx.re.match(res.header["Content-Type"],"image","io") then
                    local img = magick.load_image_from_blob(res.body);
                    if img then
                        if ngx.var.qua ~= "" then
                          local imgqua, n = ngx.re.sub(ngx.var.qua, ".([0-9]+)$", "$1");
                          img:set_quality(tonumber(imgqua));
                        else
                          img:set_quality(tonumber(85));
                        end

                        img:set_format("jpg");

                        local src_w, src_h = img:get_width(), img:get_height()
                        if dx > src_w or dy > src_h then
                          img:destroy()
                          ngx.say(res.body)
                        elseif src_w < src_h then
                          dy = src_h / (src_w / dx)
                          img:scale(dx,dy);
                          img:crop(dx,dx,0,(dy-dx)/2)
                          local ret = img:get_blob()
                          img:destroy()
                          ngx.say(ret);
                        elseif src_w > src_h then
                          dx = src_w / (src_h / dy)
                          img:scale(dx,dy);
                          img:crop(dy,dy,(dx-dy)/2,0)
                          local ret = img:get_blob()
                          img:destroy()
                          ngx.say(ret);
                        else
                          img:scale(dx,dy);
                          local ret = img:get_blob()
                          img:destroy()
                          ngx.say(ret);
                        end
                    end
                else
                    ngx.exit(res.status);
                end
              end
            ';
        }

        location ~ ^/pi/+(.*)\.([0-9]+x[0-9]+)(\.[0-9]+)?(\.auto)?\.webp { 
            set $u $1;
            set $size $2;
            set $qua $3;
            content_by_lua '
              local magick = require "magick";
              local res = ngx.location.capture("/s/"..ngx.var.u);
              if res.status == 302 then
                 local reurl, n = ngx.re.sub(res.header["Location"], "http://(.*)", "$1");
                 res = ngx.location.capture("/s/"..reurl);
              end
              if res.status == ngx.HTTP_OK and ngx.re.match(res.header["Content-Type"],"image","io") then
                  local img = magick.load_image_from_blob(res.body);
                  if img then
                      if ngx.var.qua ~= "" then
                          local imgqua, n = ngx.re.sub(ngx.var.qua, ".([0-9]+)$", "$1");
                          img:set_quality(tonumber(imgqua));
                      else
                          img:set_quality(tonumber(85));
                      end
                      img:set_format("webp");
                      ngx.header.content_type = "image/webp";
                      ngx.say(magick.thumb(img,ngx.var.size));
                  end
              else
                  ngx.exit(res.status);
              end
            ';
        }

        location ~ ^/pe/+(.*)\.([0-9]+)x([0-9]+)(\.[0-9]+)?(\.auto)?\.webp { 
            set $u $1;
            set $x $2;
            set $y $3;
            set $qua $4;
            content_by_lua '
              local dx = tonumber(ngx.var.x)
              local dy = tonumber(ngx.var.y)
              if dx ~= dy then
                ngx.say("width not eq height!")
              else
                local magick = require "magick";
                local res = ngx.location.capture("/s/"..ngx.var.u);
                if res.status == 302 then
                   local reurl, n = ngx.re.sub(res.header["Location"], "http://(.*)", "$1");
                   res = ngx.location.capture("/s/"..reurl);
                end
                if res.status == ngx.HTTP_OK and ngx.re.match(res.header["Content-Type"],"image","io") then
                    local img = magick.load_image_from_blob(res.body);
                    if img then
                        if ngx.var.qua ~= "" then
                          local imgqua, n = ngx.re.sub(ngx.var.qua, ".([0-9]+)$", "$1");
                          img:set_quality(tonumber(imgqua));
                        else
                          img:set_quality(tonumber(85));
                        end

                        img:set_format("webp");

                        local src_w, src_h = img:get_width(), img:get_height()
                        if dx > src_w or dy > src_h then
                          img:destroy()
                          ngx.say(res.body)
                        elseif src_w < src_h then
                          dy = src_h / (src_w / dx)
                          img:scale(dx,dy);
                          img:crop(dx,dx,0,(dy-dx)/2)
                          local ret = img:get_blob()
                          img:destroy()
                          ngx.say(ret);
                        elseif src_w > src_h then
                          dx = src_w / (src_h / dy)
                          img:scale(dx,dy);
                          img:crop(dy,dy,(dx-dy)/2,0)
                          local ret = img:get_blob()
                          img:destroy()
                          ngx.say(ret);
                        else
                          img:scale(dx,dy);
                          local ret = img:get_blob()
                          img:destroy()
                          ngx.say(ret);
                        end
                    end
                else
                    ngx.exit(res.status);
                end
              end
            ';
        }
        location /s/ {
            proxy_pass http://10.112.99.66:6666;
            proxy_set_header Host $host;
        }

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504 415 403 404 /blank.gif;
        location = /blank.gif {
                empty_gif;
                expires 60;
        }
        
   }

}</pre></code>
