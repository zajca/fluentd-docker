#
# Install Fluentd's (http://www.fluentd.org) td-agent and some plugins.
#
# On start, will look for /templates/td-agent.conf.j2 file which should
# be a Jinja2 template. If this file exists, the template will be
# evaluated (with data from the environment variables fed to Docker)
# and saved as /etc/td-agent/td-agent.conf.
# If the file does not exist, nothing will be done.
#
FROM debian:wheezy

# Add treasure data repository to apt and install
# Also install Python so we can run j2cli to evaluate the config template.
ADD http://packages.treasuredata.com/GPG-KEY-td-agent /tmp/
RUN apt-key add /tmp/GPG-KEY-td-agent && \
    echo "deb http://packages.treasuredata.com/2/debian/wheezy/ wheezy contrib" > /etc/apt/sources.list.d/treasure-data.list && \
    apt-get update && \
    apt-get install -y --force-yes python-setuptools adduser td-agent && \
    rm -rf /var/lib/apt/lists/*

RUN easy_install j2cli
RUN mkdir /templates

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
    fluent-plugin-tail-multiline \
    fluent-plugin-rewrite-tag-filter

# Custom plugins
ADD plugins/in_tail_extender.rb /etc/td-agent/plugin/

ADD ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
# We do NOT run as daemon
CMD ["/usr/sbin/td-agent"]
