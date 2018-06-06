FROM openjdk:7

WORKDIR /var/www

RUN git clone https://github.com/RealTimeWeb/blockpy.git

# Install Closure
RUN wget --quiet https://github.com/google/closure-library/zipball/master -O closure.zip
RUN unzip -qq closure.zip
RUN mv -f google*/* blockpy/closure-library

# Build Blockly
WORKDIR /var/www/blockpy/blockly
RUN cp msg/js/en.js ../en.js
RUN python build.py
RUN cp ../en.js msg/js/en.js

# Build skulpt
WORKDIR /var/www/blockpy/skulpt
RUN apt-get update
RUN apt-get install -y python3
RUN python3 skulpt.py dist

# Build Blockpy
WORKDIR /var/www/blockpy/
RUN python build.py
RUN cp /var/www/blockpy/blockpy_new.html /var/www/blockpy/index.html

# Install Nginx
#RUN apt-get install -y software-properties-common
RUN \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/www

COPY ./nginx.conf /etc/nginx/sites-enabled/default

EXPOSE 80

CMD ["nginx"]
