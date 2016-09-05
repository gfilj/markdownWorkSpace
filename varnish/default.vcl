# backend health checking
probe health {
    .url = "/alive";
    .timeout = 60ms;
    .interval = 2s;
    .window = 5;
    .threshold = 3;
}

backend online_tomcat1 {

     .host = "10.164.169.214";

     .port = "8181";

     .probe = health;

}
backend online_tomcat2 {

     .host = "10.164.169.215";

     .port = "8181";

     .probe = health;

}
backend online_tomcat3 {

     .host = "10.164.169.216";

     .port = "8181";

     .probe = health;

}
backend online_tomcat4 {

     . host = "10.164.169.217";

     .port = "8181";

     .probe = health;

}
backend online_tomcat5 {

      .host = "10.164.169.218";

     .port = "8181";

     .probe = health;

}
backend online_tomcat7 {

     .host = "10.164.169.220";

     .port = "8181";

     .probe = health;

}

backend online_tomcat9 {

     .host = "10.122.178.45";

     .port = "8181";

     .probe = health;

}

backend online_tomcat10 {

     .host = "10.122.178.46";

     .port = "8181";

     .probe = health;

}

# round-robin loadblancing
director dr_online round-robin {
     { .backend = online_tomcat1; }
     { .backend = online_tomcat2; }
     { .backend = online_tomcat3; }
     { .backend = online_tomcat4; }
     { .backend = online_tomcat5; }
     { .backend = online_tomcat7; }
     { .backend = online_tomcat9; }
     { .backend = online_tomcat10; }
}

# Access Control
acl internal {
   "localhost";
   "10.164.169.214";
   "10.164.169.215";
   "10.164.169.216";
   "10.164.169.217";
   "10.164.169.218";
   "10.164.169.219";
   "10.164.169.220";
   "10.164.169.221";
   "10.122.178.45";
   "10.122.178.46";
}

sub vcl_recv {
   if (req.request == "PURGE") {
        if (!client.ip ~ internal) {
            error 405 "Not allowed.";
        }
#        ban("req.url ~ "+req.url);
        error 200 "Ban added";
#        return (lookup);
    }
    if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For =
                req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }
    if (req.request != "GET" &&
      req.request != "HEAD" &&
      req.request != "PUT" &&
      req.request != "POST" &&
      req.request != "TRACE" &&
      req.request != "OPTIONS" &&
      req.request != "DELETE") {
        /* Non-RFC2616 or CONNECT which is weird. */
        return (pipe);
    }

    # Backend selection
    set req.backend = dr_online;
    
    # only cache GET and HEAD 
    if (req.request != "GET" && req.request != "HEAD") {
        /* We only deal with GET and HEAD by default */
        return (pass);
    }

    # purge request
    if (req.request == "PURGE") {
        if (!client.ip ~ internal) {
            error 405 "Not allowed.";
        }
    # purge data from cache 
        return (lookup);
    }

    # Use anonymous, cached pages if all backends are down
    if (!req.backend.healthy) {
        unset req.http.Cookie;
    }
    /* Bypass cache for large files.  The x-pipe header is
         set in vcl_fetch when a too large file is detected.*/
    if (req.http.x-pipe && req.restarts > 0) {
        unset req.http.x-pipe;
        return (pipe);
    }
    # Do not cache these paths
    if (req.url ~ "^/admin$" || req.url ~ "^/admin/.*$") {
        return (pass);
    }
    # Allow the backend to serve up stale content if it is responding slowly
    if (req.backend.healthy) {
        set req.grace = 30s;
    } else {
        set req.grace = 120s;
    }

    if (req.request == "GET"){
    #xxx    if(req.url ~ "^/api/v1/products/(.+)/users/(.+)/myComments" || req.url ~ "^/api/v1/products/(.+)/users/(.+)/commentsToMe" ||req.url ~ "^/api/v1/products/(.+)/users/(.+)/myFavComments" || req.url ~ "^/api/v1/products/(.+)/users/myInfo" || req.url ~ "^/api/v1/products/(.+)/users/melody" || req.url ~ "^/api/v1/products/(.+)/users/checklogin"){
    #xxx    }
    #xxx    else{
    #xxx        unset req.http.Cookie;
    #xxx    }

    # Strip out timestamp variable. It is only needed to clear client cache.
    # Any url parameter which is ignored by server can be configed here.
        if(req.url ~ "(\?|&)(_|ibc)=") {
            set req.url = regsuball(req.url, "(_|ibc)=[%.-_A-z0-9]+&?", "");
        }
        if(req.url ~ "(\?|&)target=") {
            set req.url = regsuball(req.url, "target=[%.-_A-z0-9]+&?", "");
        }
        if(req.url ~ "(\?|&)callback=") {
            set req.url = regsuball(req.url, "callback=[%.-_A-z0-9]+&?", "");
        }
        set req.url = regsub(req.url, "(\?&|\?|&)$", "");
    }
    # Always cache the following file types
    if (req.url ~ "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
        unset req.http.Cookie;
    }
    if(req.url ~ "/thread/check" || req.url ~ "/products/(.+)/threads/(.+)/comments/newList" || req.url ~ "/products/(.+)/threads/(.+)/comments/hotList")
    {
        unset req.http.cookie; 
    }
}

sub vcl_hit {
    if (req.request == "PURGE") {
        purge;
        error 200 "Purged.";
    }
}

sub vcl_miss {
    if (req.request == "PURGE") {
        purge;
        error 404 "Not in cache.";
    }
}

sub vcl_pass {
    if (req.request == "PURGE") {
        error 502 "PURGE on a passed object";
    }
}

# Set a header to track a cache HIT/MISS.
sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Varnish-Cache = "HIT";
    }
    else {
        set resp.http.X-Varnish-Cache = "MISS";
    }
}

sub vcl_fetch {
    # Don't cache files larger than 10MB
    if (beresp.http.Content-Length ~ "[0-9]{8,}") {
        set req.http.x-pipe = "1";
        return (restart);
    }
    #  override the default time to live of a cached object
    if ( req.url ~ "(?i)\.(png|jpg|jpeg|gif)$") {
        set beresp.ttl = 30d;
        unset beresp.http.Set-Cookie;
    } else {
    if(req.url ~ "/thread/check" || req.url ~ "/products/(.+)/threads/(.+)/comments/newList" || req.url ~ "/products/(.+)/threads/(.+)/comments/hotList"){
           set beresp.ttl = 5s;
           set beresp.http.Cache-Control = "no-cache";
        }
        else{
          set beresp.ttl = 0s;
          set beresp.http.Cache-Control = "no-cache";
        }    
    }
    # Allow items to be stale if needed
    set beresp.grace = 120s;
}