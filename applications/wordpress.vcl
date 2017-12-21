vcl 4.0;

sub vcl_recv {
    # pass wp-admin urls
    if (req.url ~ "(wp-login|wp-admin|WORDPRESS_BACKEND_URL)" || req.url ~ "preview=true" || req.url ~ "xmlrpc.php") {
        return (pass);
    }

    # pass wp-admin cookies
    if (req.http.cookie) {
        if (req.http.cookie ~ "(wordpress_|wp-settings-)") {
            return(pass);
        } else {
            unset req.http.cookie;
        }
    }
}

sub vcl_backend_response {
    # unset cookies from backendresponse
    if (!(bereq.url ~ "(wp-login|wp-admin|WORDPRESS_BACKEND_URL)"))  {
        unset beresp.http.set-cookie;
        set beresp.ttl = 1h;
    }
}