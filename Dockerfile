FROM node:10.14.1

ENV NODE_VERSION 10.14.1
ENV USER_DIR="/root"
ARG USER_ID

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    wget vim-tiny unzip python-dev python-pip

RUN wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip && \
    unzip terraform_0.11.13_linux_amd64.zip && \
    mv terraform /bin && \
    rm terraform_0.11.13_linux_amd64.zip

COPY package.json package-lock.json requirements-dev.txt /workspace/

RUN pip install -r requirements-dev.txt
RUN npm install

USER node

COPY . /workspace

ENTRYPOINT bash docker_entrypoint.sh
