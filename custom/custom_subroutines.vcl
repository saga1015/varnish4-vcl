vcl 4.0;

# Device detection
include "custom/device_detection.vcl";

# Detect bad bots
include "custom/bad_bot_detection.vcl";

# 301 redirect
include "custom/301_redirect.vcl";

# Friendly error pages
#include "custom/custom_error_pages.vcl";