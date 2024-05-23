FROM ubuntu:20.04

ARG USERNAME=camper
ARG REPO_NAME=web3-curriculum
ARG HOMEDIR=/workspace/$REPO_NAME

ENV TZ="America/New_York"

RUN apt-get update && apt-get install -y sudo

# Unminimize Ubuntu to restore man pages
RUN yes | unminimize

# Set up timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set up user, disable pw, and add to sudo group
RUN adduser --disabled-password --gecos '' ${USERNAME}
RUN adduser ${USERNAME} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install packages for projects
RUN sudo apt-get install -y curl git bash-completion man-db firefox

# Install Node LTS
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

# Rust
RUN sudo apt-get install -y build-essential
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# wasm-pack (use the manual download method here)
COPY wasm-pack-v0.12.1-x86_64-unknown-linux-musl.tar.gz /tmp/
RUN tar -xzf /tmp/wasm-pack-v0.12.1-x86_64-unknown-linux-musl.tar.gz -C /usr/local/bin/

# /usr/lib/node_modules is owned by root, so this creates a folder ${USERNAME} 
# can use for npm install --global
WORKDIR ${HOMEDIR}
RUN mkdir ~/.npm-global
RUN npm config set prefix '~/.npm-global'

# Configure course-specific environment
COPY . .
WORKDIR ${HOMEDIR}

RUN cd ${HOMEDIR} && npm install


# Configure course-specific environment
COPY . .
WORKDIR ${HOMEDIR}

RUN cd ${HOMEDIR} && npm install
