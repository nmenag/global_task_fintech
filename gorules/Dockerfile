FROM node:20

WORKDIR /app

COPY package.json ./
RUN npm install

COPY server.js ./
RUN mkdir rules

EXPOSE 8080

CMD ["npm", "start"]
