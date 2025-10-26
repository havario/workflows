#!/bin/sh

curl -Ls http://100.100.100.200/latest/meta-data/instance-id
curl -Ls http://100.100.100.200/latest/meta-data/zone-id
curl -Ls http://100.100.100.200/latest/meta-data/hostname

hostnamectl set-hostname "$(curl -Ls http://100.100.100.200/latest/meta-data/hostname)"
