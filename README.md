# citest - npm golang psql cqlsh gcloud kubectl docker-cli
# citest:ccm-pg - added cassandra ccm and postgresql server

```
docker run -ti citest

docker run -e PG_USER=test -e PG_PASS=test -e PG_AUTH=md5 -e PG_DBNAME=test citest:ccm-pg

docker exec -ti $(docker ps -lq) bash
```
