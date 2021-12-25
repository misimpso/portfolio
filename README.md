# Portfolio
_Web application powered by docker-compose, FastAPI, uvicorn, Jinja2, and nginx._

## Local Developing
---
### Build
Build image for portfolio web app, and nginx reverse proxy indiviually:
``` shell
docker build ./nginx/ -t portfolio_nginx
docker build ./portfolio/ -t portfolio_web
```
### Run
You can run the docker containers individually, but in-order to set up the network and volume creation, it's best to just run `docker-compose`. All you need to run is:
``` shell
docker-compose up
```

You should see the following output:
``` shell
$ docker-compose up          
Creating network "portfolio_default" with the default driver
Creating volume "portfolio_static_volume" with default driver
Creating portfolio_web ... done
Creating portfolio_nginx ... done
Attaching to portfolio_web, portfolio_nginx
nginx_1  | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
nginx_1  | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
nginx_1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
nginx_1  | 10-listen-on-ipv6-by-default.sh: /etc/nginx/conf.d/default.conf is not a file or does not exist, exiting
nginx_1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
nginx_1  | /docker-entrypoint.sh: Configuration complete; ready for start up
web_1    | INFO:     Started server process [1]
web_1    | INFO:     Waiting for application startup.
web_1    | INFO:     Application startup complete.
web_1    | INFO:     Uvicorn running on http://0.0.0.0:5000 (Press CTRL+C to quit)
```

### Navigate
Open up http://127.0.0.1 in a web browser to view the website.

### Cleanup
Press `CTRL+C` to stop the running containers `portfolio_web` and `portfolio_nginx`.
``` shell
Gracefully stopping... (press Ctrl+C again to force)
Stopping portfolio_nginx ... done
Stopping portfolio_web   ... done
```
The containers aren't deleted, just stopped. To fully remove them, run:
```shell
docker-compose down -v
```
You should see the following output:
```shell
$ docker-compose down -v
Removing portfolio_nginx ... done
Removing portfolio_web   ... done
Removing network portfolio_default
Removing volume portfolio_static_volume
```
---
### Details
The `docker-compose` file contains two services: `web` and `nginx`. These two services correspond to the FastAPI web-app, and the nginx reverse proxy docker images respectively. When `docker-compose up` is ran, those two services are created, along with a network `portfolio_default` and a volume `portfolio_static_volume`.

Web Service
- FastAPI Python application configured with Jinja2 template engine.
- Uvicorn ASGI service for handling asynchronous requests from nginx service.
- Listening internally on port 5000.

NGINX Service
- Reverse proxy listening on exposed port 80.
- Configured to pass requests onto upstream server aka our uvicorn/FastAPI service.

Volume
- Mounts web-app static directory `portfolio/static` into every running service.
- Used in `nginx/nginx.conf` for referencing static files.

Network
- The default network creates hostname "aliases" for every service so their respective IPs can be references without hardcoding them. The IP for the nginx container can be references as `nginx` and same for the `web` container.
- The `nginx` service is configured to listen to port `80` for http connections from the outside world.
- The `web` service is configured to expose port `5000` to the internal network for communication from the `nginx` service.

### Publish
Publish images to docker registry:
```
docker push portfolio_web
docker push portfolio_nginx
```

### Deploy
Copy docker-compose file to EC2 instances:
``` shell
scp docker-compose.yml portfolio:/home/ubuntu
```

Resources:
* [Dockerizing Django with Postgres, Gunicorn, and Nginx](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/)
* [Docker Compose Networks](https://docs.docker.com/compose/networking/)
* [Nginx and Let’s Encrypt with Docker in Less Than 5 Minutes](https://pentacent.medium.com/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71)
