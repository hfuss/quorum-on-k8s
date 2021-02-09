FROM library/node:12.20.1-stretch

RUN mkdir /racecourse
COPY . /racecourse

WORKDIR /racecourse/client
RUN npm install \
    && npm run build

WORKDIR /racecourse/server

RUN npm install

ENTRYPOINT ["npm", "start"]
