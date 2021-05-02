# Portfolio

To run development environment:
```shell
$ docker-compose -f docker-compose.dev.yml down -v
$ docker-compose -f docker-compose.dev.yml up -d --build
```

To run production environment (Django, nginx, gunicorn):
``` shell
$ docker-compose -f docker-compose.prod.yml down -v
$ docker-compose -f docker-compose.prod.yml up -d --build
$ docker-compose -f docker-compose.prod.yml exec web python manage.py migrate --noinput
$ docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --no-input --clear
```

Resources:
* [Dockerizing Django with Postgres, Gunicorn, and Nginx](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/)