/*
 * This VCL is intended to be uses with "typo3-varnish" extension from snowflakeOps
 * https://github.com/snowflakeOps/typo3-varnish
 */

vcl 4.0;

sub vcl_recv {
    # Catch BAN Command
    if(req.method == "BAN") {
        if(!client.ip ~ purgers && !std.ip(req.http.X-Real-IP, "0.0.0.0") ~ purgers) {

            if(req.http.Varnish-Ban-All == "1" && req.http.Varnish-Ban-TYPO3-Sitename) {
                ban("req.url ~ /" + " && obj.http.TYPO3-Sitename == " + req.http.Varnish-Ban-TYPO3-Sitename);
                return (synth(200, "Banned all on site "+ req.http.Varnish-Ban-TYPO3-Sitename)) ;
            }else if(req.http.Varnish-Ban-All == "1") {
                ban("req.url ~ /");
                return (synth(200, "Banned all"));
            }
        }
    }

    if(req.http.Varnish-Ban-TYPO3-Pid && req.http.Varnish-Ban-TYPO3-Sitename) {
        ban("obj.http.TYPO3-Pid == " + req.http.Varnish-Ban-TYPO3-Pid + " && obj.http.TYPO3-Sitename == " + req.http.Varnish-Ban-TYPO3-Sitename);
        return (synth(202, "Banned TYPO3 pid " + req.http.Varnish-Ban-TYPO3-Pid + " on site " + req.http.Varnish-Ban-TYPO3-Sitename));
    }else if(req.http.Varnish-Ban-TYPO3-Pid) {
        ban("obj.http.TYPO3-Pid == " + req.http.Varnish-Ban-TYPO3-Pid);
        return (synth(200, "Banned TYPO3 pid "+ req.http.Varnish-Ban-TYPO3-Pid)) ;
    }

    # do not cache TYPO3 BE User requests
    if (req.http.Cookie ~ "be_typo_user" || req.url ~ "^/typo3/") {
        return (pass);
    }

    # Lookup everything else in the Cache
    return (hash);
}

sub vcl_deliver {
	# Expires Header set by TYPO3 are used to define Varnish caching only
	# therefore do not send them to the Client
	if (resp.http.TYPO3-Pid && resp.http.Pragma == "public") {
		unset resp.http.expires;
		unset resp.http.pragma;
		unset resp.http.cache-control;
	}

	# smart Ban related
	unset resp.http.TYPO3-Pid;
	unset resp.http.TYPO3-Sitename;

	return (deliver);
}