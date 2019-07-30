#!/bin/sh
find ./koolproxyR -type f -print0 | xargs -0 md5sum | sort |grep -v ".git" | grep -v "./history" > md5.txt
