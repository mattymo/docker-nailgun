#!/bin/bash

ln -s /etc/fuel/nailgun/version.yaml /etc/nailgun/version.yaml || true
puppet apply -v /etc/puppet/modules/nailgun/examples/nailgun-only.pp

/opt/nailgun/bin/nailgun_syncdb
/opt/nailgun/bin/nailgun_fixtures

pgrep supervisord && /etc/init.d/supervisord stop


/usr/bin/supervisord -n

