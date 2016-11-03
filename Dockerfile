FROM openshift/base-centos7

MAINTAINER Greg Turner <greg.fun@gmail.com>

ENV NGINX_BASE_DIR /usr/sbin
ENV NGINX_VAR_DIR /var

LABEL io.k8s.description="Nginx static file server and reverse proxy" \
      io.k8s.display-name="nginx builder" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nginx,webserver"

COPY ./etc/yum.repos.d/nginx.repo /etc/yum.repos.d/ngnix.repo

RUN yum update --setopt=tsflags=nodocs -y

RUN yum install --setopt=tsflags=nodocs -y centos-release-scl-rh \
 && yum install --setopt=tsflags=nodocs -y bcrypt nginx \
 && yum clean all -y \
 && mkdir -p /opt/app-root/etc/nginx.conf.d /opt/app-root/run $NGINX_VAR_DIR/cache/nginx \
 && chmod -R a+rx  /usr/lib64/nginx \
 && chmod -R a+rwX $NGINX_VAR_DIR/log/nginx \
                   $NGINX_VAR_DIR/run \
                   $NGINX_VAR_DIR/cache/nginx \
                   /opt/app-root/run


COPY ./etc/ /opt/app-root/etc
COPY ./.s2i/bin/ ${STI_SCRIPTS_PATH}

RUN chown -R 1001:1001 /opt/app-root

USER 1001

EXPOSE 8080

CMD ["usage"]
