FROM ubuntu:15.04
MAINTAINER Dan Pozzie "dpozzie@gmail.com"
RUN apt-get update -qq 
RUN apt-get install -y autoconf \
                       build-essential \
                       imagemagick \
                       libbz2-dev \
                       libcurl4-openssl-dev \
                       libevent-dev \
                       libffi-dev \
                       libglib2.0-dev \
                       libjpeg-dev \
                       libmagickcore-dev \
                       libmagickwand-dev \
                       libmysqlclient-dev \
                       libncurses-dev \
                       libpq-dev \
                       libreadline-dev \
                       libsqlite3-dev \
                       libssl-dev \
                       libxml2-dev \
                       libxslt-dev \
                       libyaml-dev \
                       zlib1g-dev \
                       curl bzip2 procps autoconf \
                       build-essential cmake libcairo-dev libpango1.0-dev libxml2-dev  \
                       libgdk-pixbuf2.0-dev intltool gobject-introspection python3 valgrind \
                       git libgirepository1.0-dev \
                       gtk-doc-tools \
                       flex bison \
                       libffi-dev libcairo2-dev ttf-lyx 

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN apt-get update \
  && apt-get install -y bison ruby \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/src/ruby \
  && curl -SL "http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.1.tar.bz2" \
    | tar -xjC /usr/src/ruby --strip-components=1 \
  && cd /usr/src/ruby \
  && autoconf \
  && ./configure --disable-install-doc \
  && make \
  && apt-get purge -y --auto-remove ruby \
  && make install \
  && rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

ENV BUNDLE_APP_CONFIG $GEM_HOME


WORKDIR ~
# # Install LASEM
RUN git clone git://git.gnome.org/lasem
RUN sh lasem/autogen.sh

RUN echo "mtex2MML"
RUN echo "mtex2MML"
RUN git clone https://github.com/tadiou/mtex2MML.git
RUN mtex2MML/script/bootstrap

RUN apt-get install -y bison

# Clone Mathematical
WORKDIR $GEM_HOME
RUN git clone https://github.com/tadiou/mathematical.git mathematical-1.5.12
WORKDIR mathematical-1.5.12
RUN git reset --hard 4811419580df41a8ece81f350e8ac6ef7184dfa4
RUN /bin/bash -l -c "bundle install"
RUN script/bootstrap
RUN /bin/bash -l -c "bundle exec rake compile"

# Build the app and run it
EXPOSE 8080
RUN git clone https://github.com/tadiou/latex_converter.git ~/latex_converter
WORKDIR ~/latex_converter
RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "gem install unicorn"
CMD ["unicorn","-d","-c", "unicorn.conf"]
