FROM nginxinc/nginx-unprivileged:latest
COPY ./files/index.html /tmp
COPY ./files/nginx.conf /etc/nginx/nginx.conf