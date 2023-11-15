FROM fedora:latest
LABEL maintainer="Preston Davis <pdavis@pebcac.org>"

# User arguments
ARG USERNAME=pdavis
ARG USER_ID=1000
ARG USER_GID=$USER_UID

# Add user
RUN useradd -c "Preston Davis" -d /home/pdavis -m pdavis \
#
# Add sudo support
    && dnf install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set the default user
USER pdavis

# User home directory
ENV HOME=/home/pdavis

# Set working directory
WORKDIR $HOME

# Terminal colors with xterm
ENV TERM xterm

# Install packages
RUN sudo dnf install -y \
zsh \
git \
wget \
fontconfig \
golang \
vim-enhanced \
lua \
mkfontscale && dnf clean all && sudo ln -s /usr/bin/python3 /usr/bin/python

# Add Let's Encrypt CA to OS trusted store
RUN sudo curl -o /etc/pki/ca-trust/source/anchors/lets-encrypt-x3-cross-signed.crt https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt && \
    sudo update-ca-trust extract
    
# Install jq
# http://stedolan.github.io/jq/
RUN sudo curl -o /usr/local/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  sudo chmod +x /usr/local/bin/jq

# Install the OC client
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz > $HOME/oc.tar.gz && \
  tar xvzf $HOME/oc.tar.gz && \
  sudo mv $HOME/oc /usr/bin/oc && \
  sudo mv $HOME/kubectl /usr/bin/kubectl && \
  rm -f $HOME/oc.tar.gz

# Install cheat.sh
RUN mkdir -p $HOME/bin \
    && curl https://cht.sh/:cht.sh > $HOME/bin/cht.sh \
    && chmod +x $HOME/bin/cht.sh

# Copy Hack font into container
RUN rm -f $HOME/.local/share/fonts/*
COPY /src/complete/* $HOME/.local/share/fonts/

# Install SpaceVIM
RUN curl -sLf https://spacevim.org/install.sh | bash

# Install ohmyzsh with powerlevel10k and set it as the active theme
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
    && sed -i 's#robbyrussell#powerlevel10k/powerlevel10k#g' $HOME/.zshrc \
    && git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting \
    && git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete

# Refresh system font cache
RUN fc-cache -f -v

# Make go working directory
RUN mkdir -p $HOME/workspace/go

# Set GOPATH
ENV GOPATH $HOME/workspace/go
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 755 "$GOPATH"

# Set default terminal to zsh
CMD ["zsh"]
