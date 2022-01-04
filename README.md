# Michael Simpson's Portfolio Web-app
FastAPI web-app powered by Jinja2, uvicorn, nginx, docker-compose, AWS EC2 and AWS ECR.

## Visit my website
This application in this repo is currectly hosted on an EC2 instance and can be found here:

**http://yek.im/**

## Pre-requisites / Assumptions
This guide assumes you have some stuff setup already. What you'll need is:
* A web-server to host the docker containers.
    * This server should have ports `22`, `80` and `443` opened for SSH and HTTP/S connections.
    * I chose an AWS EC2 instance.
* Docker / docker-compose installed on both the development machine and web servers.
* Docker image repository for storing the built images.
    * Dockerhub is ok and is the default image repo for docker, but only allows one private image for the free tier.
    * I chose AWS Elastic Container Repo because of it's unlimited private-repos, low to no-cost for distributing small-footprint docker-images, and extra benefits for servicing other AWS infra.
* I am not providing my Dockefile for the `portfolio-nginx` image. I based my image from the [jonasal/nginx-certbot](https://github.com/JonasAlfredsson/docker-nginx-certbot) docker image. Please look at my [Resources](#Resources) section for a sample nginx configuration file.

## Details
The `docker-compose` file contains two services: `app` and `nginx`. These two services correspond to the FastAPI web-app, and the nginx reverse proxy docker images respectively.

### FastAPI Web-App
* PEP 517 compliant Python application.
* Built with FastAPI to handle servicing incoming requests.
* Configured with Jinja2 template engine.
* Utilizes uvicorn ASGI service for handling async requests passed from nginx service.

### Nginx
* Reverse proxy listening for HTTP/S requests on ports 80 and 443.
* Configured to pass incoming requests to upstream uvicorn container.
* Built on-top of [jonasal/nginx-certbot](https://github.com/JonasAlfredsson/docker-nginx-certbot) docker image for generating SSL certificates with certbot.
* The `nginx/certbot` docker image will save the generated SSL certificate in a docker volume called `nginx_secrets` for re-use upon service re-deployments.
    * ⚠️ Deleting this volume will cause the certificates to be regenerated. There is a very strict rate-limit for regenerating these SSL certificates, so you should rarely ever need to delete this volume.

### Docker Volumes
* Two volumes are created for storing static files and SSL certificates: `static_volume` and `nginx_secrets` respectively.
    * ⚠️ When deploying new versions of the `portfolio-app` docker image, the existing static volume needs to be explicitly deleted before spinning up the new image.

## Building
The included Dockerfile has multiple build-stages: `base`, `builder`, and `runtime`. The `base` stage is built on-top of a `python:3.10-slim-buster` image, and it installs OS packages and the application's runtime requirements. The `builder` stage installs the build requirements, and builds the `portfolio` Python wheel. Finally, the `runtime` package, copies over the built wheel, intalls it, and sets an entrypoint to run the installed package with uvicorn.

To build the runtime image, run the following command:
``` shell
$ docker build . --target runtime --tag portfolio-app:latest
```

This runtime image is ready to be ran. You can run it locally with this command:
``` shell
$ docker image run -p 5678:5678 -it portfolio-app:latest
```
The web-app should be reachable on http://localhost:5678

## Development
We can use the included Dockerfile for local development without having to push an image and run docker-compose.

First, we'll need to build just the base image. We can do that with this command:
``` shell
$ docker build . --target base --tag portfolio-app:dev
```

Now that we have the base image with all of the OS and runtime dependencies installed, we can mount the code directory and spin up the web-app manually.
``` shell
$ docker run -p 5678:5678 -itv /path/to/src:/home/portfolio portfolio-app:dev /bin/bash
root@8a8556d6d355:/home/portfolio# pip install --editable .
root@8a8556d6d355:/home/portfolio# uvicorn portfolio.main:app --host=0.0.0.0 --port=5678 --reload
INFO:     Will watch for changes in these directories: ['/home/portfolio']
INFO:     Uvicorn running on http://0.0.0.0:5678 (Press CTRL+C to quit)
INFO:     Started reloader process [63] using watchgod
INFO:     Started server process [65]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```
The web-app should be reachable on http://localhost:5678. Uvicorn is configured here to reload on any code changes.

## Deploy
To deploy the web-app, you'll need to push the `portfolio-app` and `portfolio-nginx` docker images to a docker image repo, simply copy and run the `docker-compose.yml` file on the target server.

### Tag & Push
Find a docker image repo of your choice for hosting your new images. I chose AWS Elastic Container Registry because it has a better private repo policy than Dockerhub. Follow your docker image repo's respective steps for configuring both your local and server machines for pushing and pulling images. You'll have to tag and push the `portfolio-app` and `portfolio-nginx` images.

You can do that with these commands:
``` shell
$ docker tag portfolio-app:latest your-docker-repo.com/portfolio-app:latest
$ docker push your-docker-repo.com/portfolio-app:latest
```
Update the image urls in your `docker-compose.yml` file to reference the images in your docker repo.

### Run
Copy your `docker-compose.yml` to your server. This is easy with curl:
``` shell
curl -S https://raw.githubusercontent.com/misimpso/portfolio/main/docker-compose.yml > docker-compose.yml
```
All you need to do to bring up the web-app and nginx is run:
``` shell
docker-compose up
```
This will pull the images from your docker image repo, setup the required volumes and networks, and spin up the two services: the web-app serving over the internal network on port `5678`, and nginx/certbot serving to external ports `80` and `443`.

The first time you launch the `jonasal/nginx-certbot` image, it will create the SSL certificates for your site which can take awhile. Please review both the [Good to Know](https://github.com/JonasAlfredsson/docker-nginx-certbot/blob/master/docs/good_to_know.md#good-to-know) section in the `jonasal/nginx-certbot` github page for more information / best-practices. When that is done your website should now be up and running!

### 🎊 **Congratulations!** 🎉
## Resources:
* [Dockerizing Django with Postgres, Gunicorn, and Nginx](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/)
    * Initial documentation which goes over a similar implementation but with Django.
* [`jonasal/nginx-certbot` Github Page](https://github.com/JonasAlfredsson/docker-nginx-certbot)
    * A tresure trove of information for setting up and configuring this image. This docker image is a god-send for setting up HTTPS for these types of applications, big thanks to this [@JonasAlfredsson](https://github.com/JonasAlfredsson) 👏
