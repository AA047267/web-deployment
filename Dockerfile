FROM centos:centos6
RUN yum install -y httpd
RUN yum install -y php
ADD quiz /var/www/html
EXPOSE 80
ENTRYPOINT /usr/sbin/httpd -DFOREGROUND
