FROM ubuntu:22.04

# update packages
RUN apt update

# install sudo
RUN apt install sudo

# install git
RUN apt install git -y

#install make
RUN apt install make -y

# install wget
RUN apt install wget

# install ruby
RUN apt install ruby -y

# install dependencies for lm-sensors
# build-base includes gcc
RUN apt install bison -y
RUN apt install flex -y
RUN apt install perl -y

# install dependencies for ipmitool
RUN apt install musl-dev -y
RUN apt install automake -y
RUN apt install libtool -y
RUN apt install autoconf -y
RUN apt install build-essential -y
RUN apt install libreadline-dev -y
RUN apt install gcc -y
RUN apt install libssl-dev -y

# install ruby bundler for windshield
RUN apt install ruby-bundler -y

# make a directories for our application and dependency files
RUN mkdir /windshield
RUN mkdir /windshield/dependencies

# download and install lm-sensors
WORKDIR /windshield/dependencies
RUN git clone https://github.com/lm-sensors/lm-sensors.git
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