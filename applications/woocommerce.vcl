vcl 4.0;

sub vcl_recv {
    # pass wp-admin urls
    if (req.url ~ "(wp-login|wp-admin|WORDPRESS_BACKEND_URL)" || req.url ~ "preview=true" || req.url ~ "xmlrpc.php") {
        return (pass);
    }

    # pass wp-admin cookies
    if (req.http.cookie) {
        if (req.http.cookie ~ "(wordpress_|wp-settings-)"
        || req.http.cookie ~ "(woocommerce_|wp_woocommerce_)") {
            return(pass);
        } else {
            unset req.http.cookie;
        }
    }

    # Do not cache the WooCommerce pages
    if (req.url ~ "/(cart|my-account|checkout|addons|/?add-to-cart=)"
        || req.url ~ "/(warenkorb|mein-konto|kasse|konto)") {
            return (pass);
    }
}

sub vcl_backend_response {
    # unset cookies from backendresponse
    if (!(bereq.url ~ "(wp-login|wp-admin|WORDPRESS_BACKEND_URL)")
        && !(bereq.url ~ "/(cart|my-account|checkout|product/*|addons|/?add-to-cart=)")
        && !(bereq.url ~ "/(warenkorb|mein-konto|kasse|konto|produkt/*)"))  {
        unset beresp.http.set-cookie;
        set beresp.ttl = 1h;
    }
}