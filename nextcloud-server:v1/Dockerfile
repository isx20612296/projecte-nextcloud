FROM ubuntu:latest
LABEL description="Servidor Nextcloud"
LABEL version="0.1"
LABEL author="ASIX"
RUN apt upgrade && apt update
RUN apt -y install apt-utils aptitude vim wget nmap iproute2 less curl gpg
RUN mkdir /opt/docker
COPY * /opt/docker/
WORKDIR /opt/docker/
RUN chmod +x /opt/docker/startup.sh
CMD ["/opt/docker/startup.sh"]
