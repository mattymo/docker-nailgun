#!/bin/bash

puppet apply -d -v /root/site.pp

/etc/init.d/supervisord stop
ln -s /etc/fuel/nailgun/version.yaml /etc/nailgun/version.yaml

/usr/bin/supervisord -n

