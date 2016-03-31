FROM ruby:2.2.4

MAINTAINER Dan Pozzie "dpozzie@gmail.com"
RUN apt-get update -qq 
RUN apt-get install -y curl bzip2 procps autoconf \
                       build-essential cmake libcairo-dev libpango1.0-dev libxml2-dev  \
                       libgdk-pixbuf2.0-dev intltool gobject-introspection python3 valgrind \
                       git libgirepository1.0-dev \
                       gtk-doc-tools \
                       flex bison \
                       libffi-dev libcairo2-dev ttf-lyx 



WORKDIR $GEM_HOME
RUN echo "Cloning Mathematical"
RUN git clone https://github.com/gjtorikian/mathematical.git mathematical-1.5.12
WORKDIR mathematical-1.5.12
# This brings us to version 1.5.12 which we're pegging the version at
RUN git reset --hard 4811419580df41a8ece81f350e8ac6ef7184dfa4
RUN /bin/bash -l -c "bundle install"
RUN script/bootstrap
RUN /bin/bash -l -c "bundle exec rake compile"

RUN gem install foreman
RUN gem install unicorn

RUN echo "echo2"
RUN git clone https://github.com/tadiou/latex_converter /usr/src/app
WORKDIR /usr/src/app
RUN bundle install

# Add default foreman config

ENV RAILS_ENV production
CMD ["unicorn","-d","-c", "/usr/src/app/unicorn.rb"]
# CMD foreman start -f Procfile