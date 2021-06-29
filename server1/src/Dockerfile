FROM node:16-slim

WORKDIR /usr/src/app
COPY package*.json ./
COPY . .
RUN npm install

EXPOSE 9001
CMD [ "node", "index.js" ]
