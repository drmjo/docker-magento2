FROM ubuntu:14.04.4
MAINTAINER Majan Paul <paul@urbancoyote.co>

RUN apt-get update -y
RUN apt-get install -y apache2
RUN apt-get install -y supervisor

RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN sed -i 's/80/0.0.0.0:80/g' /etc/apache2/ports.conf

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
