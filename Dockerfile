FROM ubuntu:24.04
LABEL do-not-remove=""

RUN apt-get update \
	&& apt-get -y install software-properties-common \
		curl \
		wget \
		gnupg2 \
		ca-certificates \
		apt-transport-https \
		gettext \
	&& rm -r /var/lib/apt/lists/*

RUN wget -qO - https://www.aptly.info/pubkey.txt | apt-key add - \
	&& add-apt-repository "deb http://repo.aptly.info/ squeeze main"

RUN apt-get update \
  && apt-get install -y aptly \
  && rm -r /var/lib/apt/lists/*


COPY .aptly.conf /.aptly.conf
COPY entrypoint.sh /entrypoint.sh
COPY aptly-action/aptly.sh /aptly.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["aptly"]
