FROM node:10
LABEL maintainer "Dave Dix <docker@dixieworld.co.uk>"

### Environment variables
ENV NODE_VERSION="10"
ENV CONTAINER_VERSION="0.0.3"
ENV NODE_RED_VERSION="0.19.2"
ENV GOSU_VERSION="1.10"

# Home directory for Node-RED application source code.
RUN mkdir -p /usr/src/node-red

# User data directory, contains flows, config and nodes.
RUN mkdir /data

# Install standard root CAs for https access
RUN apt-get install -y --no-install-recommends ca-certificates

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget avahi-daemon avahi-discover libnss-mdns libavahi-compat-libdnssd-dev  && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"  && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4  && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu && \
    chown root:users /usr/local/bin/gosu && \
    chmod +s /usr/local/bin/gosu && \
    mkdir -p /var/run/dbus && mkdir -p /var/run/avahi-daemon && \
    sed -i "s/#enable-dbus=yes/enable-dbus=yes/g" /etc/avahi/avahi-daemon.conf && \
    chown messagebus:messagebus /var/run/dbus && \
    chown avahi:avahi /var/run/avahi-daemon && \
    dbus-uuidgen --ensure && \
    apt-get -y autoclean && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    gosu nobody true && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    apt-get purge -y --auto-remove wget && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* 

# Add node-red user so we aren't running as root.
RUN useradd --home-dir /usr/src/node-red --no-create-home node-red \
    && chown -R node-red:node-red /data \
    && chown -R node-red:node-red /usr/src/node-red

USER node-red
# USER root

WORKDIR /usr/src/node-red

# package.json contains Node-RED NPM module and node dependencies
# The version of light-scheduler is fixed so it can be patched
# As soon as there are fixed versions on npm I'll change this
COPY --chown=node-red:node-red package.json /usr/src/node-red/
# Set the container version
RUN sed -i "s/\(node\": \"\).*\(\"\)/\1$NODE_VERSION\.\*\.\*\"/g" package.json
# Set the container version
RUN sed -i "s/\(version\": \"\).*\(\"\)/\1$CONTAINER_VERSION\"/g" package.json
# Set the node-red version to be installed
RUN sed -i "s/\(node-red\": \"\).*\(\"\)/\1$NODE_RED_VERSION\"/g" package.json
# RUN cat package.json
RUN npm install
RUN npm audit fix

# Fix up the light-scheduler Bug
COPY --chown=node-red:node-red latest/light-scheduler.js /usr/src/node-red/node_modules/node-red-contrib-light-scheduler

# node-red UI port
EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules

# CMD ["npm", "start", "--", "--userDir", "/data"]
# # CMD service dbus start && service avahi-daemon start
# CMD /bin/bash
COPY entrypoint.sh /usr/src/node-red
RUN gosu root chmod 755 /usr/src/node-red/entrypoint.sh
ENTRYPOINT /usr/src/node-red/entrypoint.sh