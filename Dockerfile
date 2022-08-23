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
    
# Install jq
# http://stedolan.github.io/jq/
RUN curl -o /usr/local/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x /usr/local/bin/jq
    
# Create needed symlinks for Python3 and Vim
#RUN ln -s /usr/bin/python3 /user/bin/python
#RUN ln -s /usr/bin/nvim /usr/bin/vim
#RUN mv /usr/bin/vi /usr/bin/oldvi && ln -s /usr/bin/nvim /usr/local/bin/vi

# User home directory
ENV HOME=/home/pdavis

# Set working directory
WORKDIR $HOME

# Install the OC client
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz > $HOME/oc.tar.gz && \
  tar xvzf $HOME/oc.tar.gz && \
  mv $HOME/oc /usr/bin/oc && \
  mv $HOME/kubectl /usr/bin/kubectl

# Install cheat.sh
RUN curl https://cht.sh/:cht.sh > /usr/local/bin/cht.sh && chmod +x /usr/local/bin/cht.sh

# Copy Hack font into container
RUN rm -f $HOME/.local/share/fonts/*
COPY /src/complete/* $HOME/.local/share/fonts/

# Install SpaceVIM
RUN curl -sLf https://spacevim.org/install.sh | bash

# Install ohmyzsh 
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Refresh system font cache
RUN fc-cache -f -v

# Make go working directory
RUN mkdir -p /home/pdavis/workspace/go

# Set GOPATH
ENV GOPATH $HOME/pdavis/workspace/go
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# Set default terminal to bash
CMD ["zsh"]