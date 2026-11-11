FROM debian:bookworm

RUN apt update && \
	apt install -y nginx openssl curl gettext-base && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*

ARG LOGIN
ARG DOMAIN_NAME

ENV DOMAIN_NAME=${DOMAIN_NAME}

RUN mkdir -p /etc/nginx/ssl

ENV SSL_CERT=/etc/nginx/ssl/inception.crt
ENV SSL_KEY=/etc/nginx/ssl/inception.key

RUN openssl req -x509 -nodes -days 365 \
	-out ${SSL_CERT} -keyout ${SSL_KEY} \
	-subj "/C=FR/ST=OCC/L=Perpignan/O=42/OU=42Perpignan/CN=${DOMAIN_NAME}/UID=${LOGIN}"

COPY ./conf/default.template /etc/nginx/sites-available/default.template

RUN envsubst '${SSL_CERT} ${SSL_KEY} ${DOMAIN_NAME}' < /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default

RUN rm /etc/nginx/sites-available/default.template

RUN chmod 755 /var/www/html

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]