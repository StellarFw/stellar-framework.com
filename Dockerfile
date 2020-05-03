FROM node:13 as build

ADD package.json /tmp
ADD yarn.lock /tmp
RUN cd /tmp && yarn install

RUN mkdir /app && cp -a /tmp/node_modudes /app
ADD ./ /app
WORKDIR /app

RUN yarn build
