FROM centos

MAINTAINER Aleksandr Didenko adidenko@mirantis.com

WORKDIR /root

RUN rm -rf /etc/yum.repos.d/*
RUN echo -e "[nailgun]\nname=Nailgun Local Repo\nbaseurl=http://10.20.0.2:8080/centos/fuelweb/x86_64/\ngpgcheck=0" > /etc/yum.repos.d/nailgun.repo
RUN yum clean all
RUN yum --quiet install -y puppet

ADD start.sh /usr/local/bin/start.sh
ADD astute.yaml /etc/astute.yaml
ADD site.pp /root/site.pp
#FIXME: generate supervisor.conf via puppet
ADD supervisord.conf /root/supervisord.conf

RUN touch /var/lib/hiera/common.yaml
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8001

CMD ["/usr/local/bin/start.sh"]
