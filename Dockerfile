# FROM alpine/git as git-themes
# COPY . /data
# WORKDIR /data
# RUN rm -rf /data/site/themes/*
# RUN git clone https://github.com/luizdepra/hugo-coder.git /data/site/themes/hugo-coder

FROM debian:buster

# Install pygments (for syntax highlighting) 
RUN apt-get -qq update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends libstdc++6 python-pygments git ca-certificates asciidoc curl \
	&& rm -rf /var/lib/apt/lists/*

# Configuration variables
ENV HUGO_VERSION 0.75.1
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.deb
ENV SITE_DIR '/usr/share/blog'

# Download and install hugo
RUN curl -sL -o /tmp/hugo.deb \
    https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    dpkg -i /tmp/hugo.deb && \
    rm /tmp/hugo.deb && \
    mkdir ${SITE_DIR}

WORKDIR ${SITE_DIR}

# Expose default hugo port
EXPOSE 1313

# Automatically build site
ONBUILD ADD site/ ${SITE_DIR}

RUN apt update
RUN apt install -y git
COPY . /data
RUN rm -rf /data/site/themes/*
RUN git clone https://github.com/kc0bfv/autophugo.git /data/site/themes/autophugo
WORKDIR /data/site
RUN hugo 
ENTRYPOINT echo "Hello world"

FROM nginx:alpine
COPY --from=0 /data/site/public /usr/share/nginx/html
