FROM node:9.11.2-jessie

LABEL maintainer.name="Alejandro Guzman"
LABEL maintainer.email="a.guillermo.guzman@gmail.com"

ENV APP /app
WORKDIR $APP

COPY ./dev/package.json .
COPY ./dev/webpack ./webpack

RUN npm install

EXPOSE 3000

CMD ["npm", "run", "server"]