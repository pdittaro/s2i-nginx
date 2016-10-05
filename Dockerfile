FROM openshift/base-centos7

MAINTAINER Greg Turner <greg.fun@gmail.com>

ENV NGINX_VERSION 1.8
ENV NGINX_BASE_DIR /opt/rh/rh-nginx18/root
ENV NGINX_VAR_DIR /var/opt/rh/rh-nginx18
ENV LETSENCRYPT_BASE /opt/app-root/letsencrypt
ENV LETSENCRYPT_LOGS /opt/app-root/letsencrypt/logs
ENV LETSENCRYPT_CONFIG /opt/app-root/letsencrypt/config
ENV LETSENCRYPT_LIB /var/lib/letsencrypt

LABEL io.k8s.description="Nginx static file server and reverse proxy" \
      io.k8s.display-name="nginx builder ${NGINX_VERSION}" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nginx,webserver"


RUN yum install --setopt=tsflags=nodocs -y centos-release-scl-rh \
 && yum install --setopt=tsflags=nodocs -y bcrypt rh-nginx${NGINX_VERSION/\./} \
 && yum clean all -y \
 && mkdir -p /opt/app-root/etc/nginx.conf.d /opt/app-root/run \
 && chmod -R a+rx  $NGINX_VAR_DIR/lib/nginx \
 && chmod -R a+rwX $NGINX_VAR_DIR/lib/nginx/tmp \
                   $NGINX_VAR_DIR/log \
                   $NGINX_VAR_DIR/run \
                   /opt/app-root/run

RUN yum install --setopt=tsflags=nodocs -y epel-release \
	&& yum install --setopt=tsflags=nodocs -y certbot \
	&& mkdir -p $LETSENCRYPT_LIB $LETSENCRYPT_BASE $LETSENCRYPT_LOGS $LETSENCRYPT_CONFIG \
	&& chmod -R a+rwX $LETSENCRYPT_BASE

COPY ./etc/ /opt/app-root/etc
COPY ./.s2i/bin/ ${STI_SCRIPTS_PATH}

RUN chown -R 1001:1001 /opt/app-root

USER 1001

EXPOSE 8080

CMD ["usage"]
