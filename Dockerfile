# build environment
FROM node:13.12.0-alpine as build

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

COPY package.json ./
COPY package-lock.json ./

RUN npm ci --production --silent

COPY ./public ./public
COPY ./src ./src
COPY ./nginx.conf ./
COPY ./gzip.conf ./
COPY ./env.sh ./
COPY ./.env ./

RUN npm run build

# production environment
FROM nginxinc/nginx-unprivileged

WORKDIR /etc/nginx/conf.d
COPY --from=build /app/nginx.conf ./default.conf
COPY --from=build /app/gzip.conf ./gzip.conf

WORKDIR /usr/share/nginx/html
COPY --from=build /app/build .
COPY --from=build /app/env.sh .
COPY --from=build /app/.env .

USER root
RUN chown nginx:nginx /usr/share/nginx/html
RUN chown nginx:nginx ./env.sh && chmod +x ./env.sh
RUN touch ./env-config.js
RUN chown nginx:nginx ./env-config.js
USER nginx

EXPOSE 8080

CMD ["/bin/sh", "-c", "/usr/share/nginx/html/env.sh && nginx -g \"daemon off;\""]