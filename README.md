# Portfolio

To run development environment:
```shell
$ docker-compose -f docker-compose.dev.yml down -v
$ docker-compose -f docker-compose.dev.yml up -d --build
```

To run production staging environment (Django, nginx, gunicorn):
``` shell
$ docker-compose -f docker-compose.stage.yml down -v
$ docker-compose -f docker-compose.stage.yml up -d --build
$ docker-compose -f docker-compose.stage.yml exec web python manage.py migrate --noinput
$ docker-compose -f docker-compose.stage.yml exec web python manage.py collectstatic --no-input --clear
```

To just build images:
``` shell
docker-compose -f docker-compose.stage.yml build
```

Publish images to docker registry:
```
docker push misimpso/portfolio_web
docker push misimpso/portfolio_nginx
```

Copy files to EC2 instance
``` shell
scp docker-compose.prod.yml portfolio:/home/ubuntu/yekim
scp .env.prod portfolio:/home/ubuntu/yekim
```

Resources:
* [Dockerizing Django with Postgres, Gunicorn, and Nginx](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/)