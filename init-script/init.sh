#!/bin/bash
Docker_Yumrepo_file='https://raw.githubusercontent.com/kissingwolf/docker-basic/master/init-script/docker.repo'

if [ $(whoami) ! = 'root' ] ; then 
	echo " Mast run as root "
	exit
fi

yum install -y wget

wget $Docker_Yumrepo_file -O /etc/yum.repos.d/docker.repo

yum makecache

yum install -y docker-engine.x86_64

systemctl enable docker

systemctl start docker

