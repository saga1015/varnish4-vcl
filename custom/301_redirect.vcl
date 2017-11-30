vcl 4.0;

sub vcl_synth {

    # 301 redirect
    if (resp.status == 720) {
        set resp.http.Location = resp.reason;
        set resp.status = 301;
        return (deliver);
    }

}