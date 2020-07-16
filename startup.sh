#!/bin/bash
set -e
rm -f /etc/httpd/run/httpd.pid
exec httpd -DFOREGROUND
