FROM node:iron as build

WORKDIR /app

COPY [".", "."]

RUN ["make", "release"]

FROM nginx:alpine

COPY --from=build ["/app/dist/release", "/usr/share/nginx/html"]

EXPOSE 80/tcp