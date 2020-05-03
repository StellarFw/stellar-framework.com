FROM node:13 as build
ADD package.json /tmp
ADD yarn.lock /tmp
RUN cd /tmp && yarn install
RUN mkdir /app && cp -a /tmp/node_modudes /app
ADD ./ /app
WORKDIR /app
RUN yarn build

FROM nginx:1.17.10 as webserver
COPY nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /usr/share/nginx/html
COPY --from=public /app/dist ./
