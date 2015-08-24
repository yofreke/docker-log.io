# 1. Base images
FROM       ubuntu:14.04
MAINTAINER Joe Brown <jbrown@weeby.co>

RUN apt-get update && \
      apt-get install -y python-pip wget default-jre

# Install supervisord
RUN pip install supervisor && \
    mkdir /etc/supervisord.d

# Install a log.io
RUN apt-get update && \
      apt-get install -y npm nodejs
RUN ln -s `which nodejs` /usr/bin/node
RUN npm install -g log.io --user "root"

# Install logstash
RUN wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb http://packages.elasticsearch.org/logstash/1.5/debian stable main" | tee -a /etc/apt/sources.list
RUN apt-get update && \
      apt-get install -y logstash

# Add custom plugin gem
ADD logstash-output-logio/logstash-output-logio.tar.gz /etc/logstash/
RUN cd /opt/logstash && \
    bin/plugin install --no-verify /etc/logstash/logstash-output-logio-0.0.0.gem

# Add conf files
ADD conf/supervisord.conf /etc/supervisord.d/supervisord.conf
ADD conf/log.io /root/.log.io
ADD conf/logstash /etc/logstash/conf.d

# Start supervisord
CMD ["supervisord", "-c", "/etc/supervisord.d/supervisord.conf"]
