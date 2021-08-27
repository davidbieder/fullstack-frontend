# build environment
FROM node:13.12.0-alpine as build
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY package.json ./
COPY package-lock.json ./
RUN echo $(pwd)
RUN echo $(ls -la)
RUN npm ci --production --silent
COPY ./public ./public
COPY ./src ./src
COPY ./nginx.conf ./
RUN npm run build

# production environment
FROM nginxinc/nginx-unprivileged
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080