FROM ubuntu:latest
LABEL description="Servidor Nextcloud"
LABEL version="0.1"
LABEL author="ASIX"
RUN ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime
RUN apt upgrade && apt update
RUN apt -y install apt-utils aptitude vim wget nmap iproute2 less curl gpg apache2 mariadb-server 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
RUN apt -y install libapache2-mod-php7.4 php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl php7.4-gmp php7.4-bcmath php-imagick php7.4-xml php7.4-zip
RUN mkdir /opt/docker
COPY * /opt/docker/
WORKDIR /opt/docker/
RUN chmod +x /opt/docker/startup.sh
CMD ["/opt/docker/startup.sh"]
