FROM nginx:alpine
COPY ./out/release /usr/share/nginx/html
EXPOSE 80/tcp