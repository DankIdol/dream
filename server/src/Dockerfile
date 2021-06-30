FROM node:16-slim

WORKDIR /usr/src/app
COPY package*.json ./
COPY . .
RUN npm install

ENV PORT 9001
ENV KEY "sample_key"

EXPOSE 9001
CMD [ "node", "index.js" ]
