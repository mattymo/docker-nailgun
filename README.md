docker-nailgun
===================

Fuel docker-nailgun container


```bash
cp /etc/astute.yaml ./

# build
docker build -t fuel/nailgun ./

# run AFTER storage-puppet and storage-log

docker run \
  -h $(hostname -f) \
  -p 8001:8001 \
  -d -t \
  -v /var/www/nailgun:/var/www/nailgun:ro \
  -v /etc/:/etc/fuel:ro \
  --volumes-from storage-puppet \
  --volumes-from storage-log \
  --name fuel-nailgun \
  fuel/nailgun

```
