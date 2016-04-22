FROM ubuntu:14.04.4
MAINTAINER Majan Paul <paul@urbancoyote.co>

RUN apt-get install -y apache2

RUN sed -i 's/80/0.0.0.0:80/g' /etc/apache2/ports.conf
EXPOSE 80
