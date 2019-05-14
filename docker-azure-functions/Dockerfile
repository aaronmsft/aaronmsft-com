FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"

WORKDIR /home/

RUN echo "installing jq, etc" \
    && apt-get update \
    && apt-get install -y jq curl apt-transport-https lsb-release gpg apt-utils zip  build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN echo "installing .net sdk" \
    && apt-get update \
    && curl -O https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get install -y apt-transport-https software-properties-common \
    && add-apt-repository universe \
    && apt-get update \
    && apt-get install -y dotnet-sdk-2.2 \
    && rm -rf /var/lib/apt/lists/*

RUN echo "install nodejs" \
    && curl -sL https://deb.nodesource.com/setup_11.x | bash \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN echo "installing azure functions cli" \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list \
    && apt-get update \
    && apt-get install -y azure-functions-core-tools python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN echo "installing azure cli" \
    && AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y azure-cli \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 7071

WORKDIR /pwd/

CMD [ "bash" ]
