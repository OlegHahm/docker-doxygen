FROM alpine:3.21.2
LABEL maintainer="Oleg Hahm <oleg@riot-os.org>"
RUN apk upgrade -q -U -a \
	&& apk --update add \
	nginx \
	fcgiwrap \
	doxygen \
	git \
	openssh-client \
	shadow \
	graphviz \
	font-noto \
	apache2-utils \
    make \
    python3 \
    py3-yaml \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /var/www/cgi \
	&& mkdir -p /var/data/ \
	&& mkdir -p /var/data/html \
	&& mkdir -p /var/data/config \
	&& mkdir -p /var/data/repo \
	&& mkdir -p /var/run/hook/ \
	&& mkdir -p /usr/share/doc/doxygen/ \
	&& chown -R nginx:nginx /var/run/hook/ \
	&& chown -R nginx:nginx /var/data/repo \
	&& chown -R nginx:nginx /var/data/html

COPY nginx/hook.cgi /var/www/cgi/
COPY nginx/index.html /var/data/html/
COPY nginx/default.conf /etc/nginx/conf.d/
COPY nginx/nginx.conf /etc/nginx/
COPY gen-doxygen /usr/bin/
COPY ssh/ssh_config /etc/ssh/
COPY doxygen/Doxyfile /usr/share/doc/doxygen/
COPY run.sh /run.sh

RUN chmod +x /var/www/cgi/hook.cgi /run.sh

VOLUME /var/data/
EXPOSE 80
CMD ["/run.sh"]
