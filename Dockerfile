FROM fedora:latest
LABEL maintainer="Preston Davis pdavis@pebcac.org"
USER root

# Install packages
RUN dnf install -y \
zsh \
git \
wget \
fontconfig \
golang \
neovim \
net-tools \
lua \
exa \
podman \
mkfontscale && dnf clean all

# Terminal colors with xterm
ENV TERM xterm

# Set git variables
RUN echo "git config --global http.sslVerify false" >> /etc/bashrc
RUN echo "git config --global user.name 'Preston Davis'" >> /etc/bashrc
RUN echo "git config --global user.email 'pdavis@pebcac.org'" >> /etc/bashrc
RUN echo "git config --global user.name 'Preston Davis'" >> /etc/zshrc
RUN echo "git config --global user.email 'pdavis@pebcac.org'" >> /etc/zshrc

# Add Let's Encrypt CA to OS trusted store
RUN curl -o /etc/pki/ca-trust/source/anchors/lets-encrypt-x3-cross-signed.crt https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt && \
    update-ca-trust extract

# User home directory
ENV HOME=/home/pdavis

# Set working directory
WORKDIR $HOME

# Install ohmyzsh 
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install jq
# http://stedolan.github.io/jq/
RUN curl -o /usr/local/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x /usr/local/bin/jq

# Install cheat.sh
RUN curl https://cht.sh/:cht.sh > /usr/local/bin/cht.sh && chmod +x /usr/local/bin/cht.sh

# Copy Hack font into container
RUN rm -f $HOME/.local/share/fonts/*
COPY /src/complete/* $HOME/.local/share/fonts/

# Install SpaceVIM
RUN curl -sLf https://spacevim.org/install.sh | bash

# Refresh system font cache
RUN fc-cache -f -v

# Make go working directory
RUN mkdir -p /home/pdavis/workspace/go

# Install ohmybash
# RUN bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"

# Set the ZSH theme
ENV ZSH_THEME=powerline

# Set default terminal to bash
CMD ["zsh"]