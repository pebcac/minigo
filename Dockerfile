FROM redhat/ubi8-minimal:latest
LABEL maintainer="Preston Davis pdavis@pebcac.org"
USER root

# Install packages
#RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN microdnf install -y \
git \
wget \
fontconfig \
golang \
vim-enhanced \
net-tools \
lua \
vim-minimal \
mkfontscale && microdnf clean all

# Terminal colors with xterm
ENV TERM xterm

# Set git variables
RUN echo "git config --global http.sslVerify false" >> /etc/bashrc
RUN echo "git config --global user.name 'Preston Davis'" >> /etc/bashrc
RUN echo "git config --global user.email 'pdavis@redhat.com'" >> /etc/zshrc

# Install jq
# http://stedolan.github.io/jq/
RUN curl -o /usr/local/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x /usr/local/bin/jq

# Add Let's Encrypt CA to OS trusted store
RUN curl -o /etc/pki/ca-trust/source/anchors/lets-encrypt-x3-cross-signed.crt https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt && \
    update-ca-trust extract

# User home directory
ENV HOME=/home/pdavis

# Set working directory
WORKDIR $HOME

# Install cheat.sh
#RUN mkdir -p ~/bin/ && curl https://cht.sh/:cht.sh > ~/bin/cht.sh && chmod +x ~/bin/cht.sh

# Install SpaceVIM
RUN curl -sLf https://spacevim.org/install.sh | bash

# Copy Hack font into container
RUN rm -f /home/pdavis/.local/share/fonts/*
COPY /src/complete/* /home/pdavis/.local/share/fonts/

# Refresh system font cache
RUN fc-cache -f -v

# Make go working directory
RUN mkdir -p /home/pdavis/workspace/go

# Install ohmybash
RUN bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"

# Set the ZSH theme
ENV OSH_THEME=powerline

# Set default terminal to bash
CMD ["bash"]