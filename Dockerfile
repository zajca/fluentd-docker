#
# Install Fluentd's (http://www.fluentd.org) td-agent and some plugins.
#
FROM debian:wheezy

# Add treasure data repository to apt and install
ADD http://packages.treasuredata.com/GPG-KEY-td-agent /tmp/
RUN apt-key add /tmp/GPG-KEY-td-agent && \
    apt-get update && \
    echo "deb http://packages.treasuredata.com/2/debian/wheezy/ wheezy contrib" > /etc/apt/sources.list.d/treasure-data.list && \
    apt-get update && \
    apt-get install -y --force-yes adduser td-agent && \
    rm -rf /var/lib/apt/lists/*

# Use jemalloc to avoid memory fragmentation
ENV LD_PRELOAD /opt/td-agent/embedded/lib/libjemalloc.so

# Set Max number of file descriptors for the safety sake
# see http://docs.fluentd.org/en/articles/before-install
RUN ulimit -n 65536

# Install plugins
RUN td-agent-gem install \
    fluent-plugin-s3 \
    fluent-plugin-dynamodb \
    fluent-plugin-loggly \
    fluent-plugin-tail-multiline

# Custom plugins
ADD plugins/in_tail_extender.rb /etc/td-agent/plugin/

# We do NOT run as daemon
CMD ["/usr/sbin/td-agent"]