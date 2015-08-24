# 1. Base images
FROM       ubuntu:14.04
MAINTAINER Joe Brown <jbrown@weeby.co>

RUN apt-get update && \
      apt-get install -y python-pip wget default-jre
RUN apt-get install -y git

# Install supervisord
RUN pip install supervisor && \
    mkdir /etc/supervisord.d

# Install npm and node
RUN apt-get update && \
      apt-get install -y npm nodejs
RUN ln -s `which nodejs` /usr/bin/node

# Install logstash
RUN wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb http://packages.elasticsearch.org/logstash/1.5/debian stable main" | tee -a /etc/apt/sources.list
RUN apt-get update && \
      apt-get install -y logstash

# Clone and install log.io
RUN git clone https://github.com/yofreke/Log.io && \
    cd /Log.io && \
    npm install && \
    npm run prepublish && \
    npm link

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
