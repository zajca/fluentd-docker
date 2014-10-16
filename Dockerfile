#
# Install Fluentd's (http://www.fluentd.org) td-agent and some plugins.
#
FROM debian:wheezy

# Add treasure data repository to apt and install
RUN apt-get update && \
    apt-get install -y adduser curl && \
    curl http://packages.treasuredata.com/GPG-KEY-td-agent | apt-key add - && \
    echo "deb http://packages.treasuredata.com/2/debian/wheezy/ wheezy contrib" > /etc/apt/sources.list.d/treasure-data.list && \
    apt-get update && \
    apt-get install -y --force-yes td-agent && \
    rm -rf /var/lib/apt/lists/*
