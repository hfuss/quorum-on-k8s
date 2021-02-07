FROM ghcr.io/hfuss/quorum-base:latest

# TODO might be better to just fork quorum-tools

RUN curl -sL https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb -o dumb-init_1.2.5_amd64.deb
RUN dpkg -i dumb-init_*.deb
