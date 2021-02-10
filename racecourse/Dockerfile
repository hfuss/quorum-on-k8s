FROM library/node:12.20.1-stretch

RUN mkdir /racecourse
COPY . /racecourse

WORKDIR /racecourse/client
RUN npm install \
    && npm run build

#WORKDIR /racecourse/contracts
#RUN npm install -g solc@0.4.24 \
#    && solcjs --bin --abi Race.sol

WORKDIR /racecourse/server

RUN npm install

ENTRYPOINT ["npm", "start"]
