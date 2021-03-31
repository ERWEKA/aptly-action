FROM ubuntu:20.04
LABEL do-not-remove=""

#RUN useradd -m -r -u 999 github
#WORKDIR /home/github
#RUN chown 999:998 /home/github


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
    && apt-get install -y aptly python3-pip \
    && python3 -m pip install awscli

#COPY Erweka_Root_CA_X1.crt .
#RUN mkdir /usr/local/share/ca-certificates/extra \
#    && cp Erweka_Root_CA_X1.crt /usr/local/share/ca-certificates/extra/Erweka_Root_CA_X1.crt \
#    && update-ca-certificates

#USER github
COPY .aptly.conf /home/github/.aptly.conf
#COPY gpg_public.key /home/github/gpg_public.key
COPY entrypoint.sh /home/github/entrypoint.sh
COPY aptly-action/aptly.sh /home/github/aptly.sh

ENTRYPOINT ["/home/github/entrypoint.sh"]
CMD ["aptly"]