FROM nginx:1.19.0-alpine

RUN apk update \
    && apk add curl

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d