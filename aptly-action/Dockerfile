FROM ubuntu:20.04
LABEL do-not-remove=""
RUN useradd aptly
WORKDIR /home/aptly
RUN chown aptly:aptly /home/aptly


RUN apt-get update \
	&& apt-get -y install software-properties-common \
		curl \
		wget \
		gnupg2 \
		ca-certificates \
		apt-transport-https \
	&& rm -r /var/lib/apt/lists/*

RUN wget -qO - https://www.aptly.info/pubkey.txt | apt-key add - \
	&& add-apt-repository "deb http://repo.aptly.info/ squeeze main"

RUN apt-get update \
    && apt-get install -y aptly python3-pip \
    && python3 -m pip install awscli

COPY Erweka_Root_CA_X1.crt .
RUN mkdir /usr/local/share/ca-certificates/extra \
    && cp Erweka_Root_CA_X1.crt /usr/local/share/ca-certificates/extra/Erweka_Root_CA_X1.crt \
    && update-ca-certificates

USER aptly

COPY .aptly.conf /home/aptly/.aptly.conf
COPY gpg_public.key /home/aptly/gpg_public.key
COPY entrypoint.sh /home/aptly/entrypoint.sh

ENTRYPOINT ["/home/aptly/entrypoint.sh"]
CMD ["aptly"]