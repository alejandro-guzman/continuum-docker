FROM node:9.11.2-jessie

LABEL maintainer.name="Alejandro Guzman"
LABEL maintainer.email="a.guillermo.guzman@gmail.com"

ENV APP /app
WORKDIR $APP

COPY ./dev/package.json .
RUN npm install

#COPY ./dev/webpack ./webpack
#COPY ./dev/scripts ./scripts

EXPOSE 3000

CMD ["npm", "run", "server"]
