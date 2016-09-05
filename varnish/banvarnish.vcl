# backend health checking
probe health {
    .url = "/alive";
    .timeout = 60ms;
    .interval = 2s;
    .window = 5;
    .threshold = 3;
}

backend simg0 {
     .host = "10.102.135.130";
     .port = "8080";
     .probe = health;
}
backend simg1 {
     .host = "10.102.135.131";
     .port = "8080";
     .probe = health;
}
backend simg2 {
     .host = "10.102.135.132";
     .port = "8080";
     .probe = health;
}
backend simg3 {
     .host = "10.102.135.133";
     .port = "8080";
     .probe = health;
}
backend simg4 {
     .host = "10.102.135.134";
     .port = "8080";
     .probe = health;
}
backend simg5 {
     .host = "10.102.135.135";
     .port = "8080";
     .probe = health;
}
director baz round-robin {
        { .backend = simg0; }
        { .backend = simg1; }
        { .backend = simg2; }
        { .backend = simg3; }
        { .backend = simg4; }
        { .backend = simg5; }
}
acl purge {
        "localhost";
    	"10.102.135.128";
	    "10.102.135.128";
}
 sub vcl_recv {
	if (req.http.X-Purge-Regex) {
 	       if (!client.ip ~ purge) {
        	    error 405 "Varnish says nope, not allowed.";
       		}
        	ban_url(req.http.X-Purge-Regex);
        	error 200 "The URL has been Banned.";
	}
	   	 set req.backend = baz;
}
sub vcl_hash {
	hash_data(req.url);
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
                error 200 "Purged.";
        }
}