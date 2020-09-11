FROM nginx:alpine
COPY ./dist/release /usr/share/nginx/html
EXPOSE 80/tcp