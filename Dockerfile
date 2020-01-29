FROM ubuntu:18.04

LABEL MAINTAINERS="Ben Engel <benjamin.engel@ymail.com>"

ARG asciidoctor_version=2.0.10
ARG asciidoctor_pdf_version=1.5.0.rc.1
ARG asciidoctor_diagram_version=2.0.0
ARG asciidoctor_revealjs_version=3.1.0
ARG asciidoctor_mathematical_version=0.3.1


ENV ASCIIDOCTOR_VERSION=${asciidoctor_version} \
  ASCIIDOCTOR_PDF_VERSION=${asciidoctor_pdf_version} \
  ASCIIDOCTOR_DIAGRAM_VERSION=${asciidoctor_diagram_version} \
  ASCIIDOCTOR_REVEALJS_VERSION=${asciidoctor_revealjs_version} \
  ASCIIDOCTOR_MATHEMATICAL_VERSION=${asciidoctor_mathematical_version}

RUN apt-get update && apt-get upgrade -y 

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
           software-properties-common \
           ruby \
           ruby-dev \
           make \
           cmake \ 
           build-essential \ 
           pandoc \
           graphviz \
           python3-dev \
           python3-pip \
           python3-setuptools \
          git \ 
          default-jre \
          curl \
          bison \
          flex \
          libffi-dev \
          libxml2-dev \
          libgdk-pixbuf2.0-dev \
          libcairo2-dev \
          libpango1.0-dev \
          fonts-lyx \
          gnupg \
          && apt-get clean \
          && rm -rf /var/lib/apt/lists/* \
          && rm -rf /tmp/*

# install nodejs for compiling stylesheets
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -E \
  && apt-get -y install nodejs

# Installing Ruby Gems needed in the image
# including asciidoctor itself
RUN gem install --no-document --pre \
    "asciidoctor:${ASCIIDOCTOR_VERSION}" \
    "asciidoctor-diagram:${ASCIIDOCTOR_DIAGRAM_VERSION}" \
    "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}" \
    "asciidoctor-mathematical:${ASCIIDOCTOR_MATHEMATICAL_VERSION}" \
    "asciidoctor-revealjs:${ASCIIDOCTOR_REVEALJS_VERSION}" \
    coderay \
    bundler \
    rack
    
# Installing Python dependencies for additional
# functionalities as diagrams or syntax highligthing
RUN  pip3 install --no-cache-dir \
    actdiag \
    'blockdiag[pdf]' \
    nwdiag \
    seqdiag


WORKDIR /opt

# install custom version of rouge from repo (with msdl highlighting)
RUN git clone https://github.com/engelben/rouge.git \
  && bundle config --global silence_root_warning 1 \
  && cd rouge \
  && bundle install --path vendor \
  && bundler exec rake build \
  && gem install ./pkg/rouge-3.14.0.gem


# install plantuml
RUN mkdir -p plantuml \
  && cd plantuml \
  && curl -JLO http://sourceforge.net/projects/plantuml/files/plantuml.jar/download \
  && touch /usr/local/bin/plantuml \
  && echo "#!/bin/sh" >> /usr/local/bin/plantuml \
  && echo  'java -jar /opt/plantuml/plantuml.jar "\$@"' >> /usr/local/bin/plantuml \
  && chmod a+x /usr/local/bin/plantuml


# install asciidoctor stylesheet factory
RUN git clone https://github.com/engelben/asciidoctor-stylesheet-factory.git \
  && cd asciidoctor-stylesheet-factory \
  && bundle \
  && npm i \
  && compass compile 
  
# install revealjs
RUN git clone https://github.com/hakimel/reveal.js.git \
  && cd reveal.js \
  && npm i

WORKDIR /root

RUN git clone https://oauth2:c_a1ZcwxKG5T_QePunb9@gitlab.com/Nanuk/bashsettings.git \
&& mv bashsettings/.asciidoc_snippets /root/.asciidoc_snippets \
&& mv bashsettings/.dir_colors /root/.dir_colors \
&& mv bashsettings/.profile /root/.profile \
&& mv bashsettings/.useralias /root/.useralias \
&& mv bashsettings/.usersettings /root/.usersettings \
&& mv bashsettings/.vimrc /root/.vimrc \
&& mv bashsettings/.bashrc /root/.bashrc

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash", "-l"]
