#! /bin/sh

# you can do something here
# this shell scripts will run at the end of build.py scripts

tar_name="koolproxyR.tar.gz"

mkdir -p history
if [ ! -f ./history/version ]; then
	touch ./history/version
fi

version_old=`cat history/version | sed -n '$p' | cut -d \  -f1`
version_new=`cat version |sed -n 1p`
md5_new=` md5sum $tar_name | cut -d \  -f1`
# 保证md5连续性
wget -O ./history/version https://shaoxia1991.coding.net/p/koolproxyr/d/koolproxyr/git/raw/master/history/version
if [ -f ./$tar_name ]; then
	if [ "$version_old" != "$version_new" ]; then
		mkdir ./history/$version_new/
		cp ./$tar_name ./history/$version_new/
		echo $version_new $md5_new >> ./history/version
	fi
fi
		
