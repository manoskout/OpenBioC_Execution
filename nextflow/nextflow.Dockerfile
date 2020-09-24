FROM openjdk:11.0.8-slim-buster
MAINTAINER Manos Koutoulakis <manos.koutoulak@gmail.com>

# Client Variables

ENV FLASK_APP client.py
ENV FLASK_RUN_HOST 0.0.0.0
ENV FLASK_ENV development

# Required dependencies
RUN apt-get update \
	&& apt-get install -y gcc musl-dev

RUN apt-get install -y python-pip curl jq


# install nextflow 
RUN curl -s https://get.nextflow.io | bash \
 	&& mv nextflow /usr/local/bin/

# install python 
RUN apt-get install -y python3
# CMD [""]
