FROM node:9
LABEL maintainer "Dave Dix <docker@dixieworld.co.uk>"

### Environment variables
ENV NODE_RED_VERSION="0.18.4"
ENV GOSU_VERSION="1.10"

# Home directory for Node-RED application source code.
RUN mkdir -p /usr/src/node-red

# User data directory, contains flows, config and nodes.
RUN mkdir /data

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates avahi-daemon avahi-discover libnss-mdns libavahi-compat-libdnssd-dev  && \
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
    apt-get purge -y --auto-remove ca-certificates wget && \
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
# The versions of homekit and light-scheduler are fixed so they can be patched
# As soon as there are fixed versions on npm I'll change this
COPY package.json /usr/src/node-red/
RUN npm install
RUN npm install node-red-contrib-huemagic@>1.4.0 \
    node-red-contrib-homekit@>0.2.1 \
    node-red-contrib-light-scheduler@>0.0.11 \
    node-red-node-wol

# Fix up the HomeKit Bug
COPY latest/homekit.js /usr/src/node-red/node_modules/node-red-contrib-homekit
COPY latest/light-scheduler.js /usr/src/node-red/node_modules/node-red-contrib-light-scheduler
COPY latest/settings.js /data

# User configuration directory volume
EXPOSE 1880

# # Environment variable holding file path for flows configuration
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules

# CMD ["npm", "start", "--", "--userDir", "/data"]
# # CMD service dbus start && service avahi-daemon start
# CMD /bin/bash
COPY entrypoint.sh /usr/src/node-red
RUN gosu root chmod 755 /usr/src/node-red/entrypoint.sh
ENTRYPOINT /usr/src/node-red/entrypoint.sh