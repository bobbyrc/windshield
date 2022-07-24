FROM alpine:3.16

# update packages
RUN apk update

# install sudo
RUN apk add sudo

# install ruby
RUN apk add ruby

# intall wget to get dependencies
RUN apk add wget

#install make
RUN apk add make

# install git
RUN apk add git

# install dependencies for lm-sensors
# build-base includes gcc
RUN apk add build-base
RUN apk add bison
RUN apk add flex
RUN apk add perl

# install dependencies for ipmitool
RUN apk add automake
RUN apk add libtool
RUN apk add autoconf
RUN apk add readline-dev

# install ruby bundler for windshield
RUN apk add ruby-bundler

# make a directories for our application and dependency files
RUN mkdir /windshield
RUN mkdir /windshield/dependencies

# download and install lm-sensors
WORKDIR /windshield/dependencies
RUN wget -O lm-sensors.tar.gz https://github.com/lm-sensors/lm-sensors/archive/refs/tags/V3-6-0.tar.gz
RUN mkdir lm-sensors
RUN tar -xf lm-sensors.tar.gz -C ./lm-sensors --strip-components 1
WORKDIR /windshield/dependencies/lm-sensors
RUN make all
RUN make install

# download and install ipmitool
WORKDIR /windshield/dependencies
RUN git clone https://github.com/ipmitool/ipmitool.git
WORKDIR /windshield/dependencies/ipmitool
RUN ./bootstrap && ./configure && make && sudo make install

# copy windshield files into container
COPY ./src/* /windshield
WORKDIR /windshield

# install ruby gems needed for windshield
RUN bundler install

# run windshield
CMD [ "/windshield/Fan-Control-CLI.rb", "start" ]