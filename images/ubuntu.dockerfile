FROM ubuntu:22.04
# Source: https://github.com/ogra1/snapd-docker/blob/master/build.sh

ENV container docker
ENV PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y fuse snapd snap-confine squashfuse sudo systemd curl \
    && apt-get clean \
    && dpkg-divert --local --rename --add /sbin/udevadm \
    && ln -s /bin/true /sbin/udevadm

RUN systemctl enable snapd

VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3

# install thin-edge.io
RUN curl -fsSL https://thin-edge.io/install.sh | sh -s

# install sm-plugin
COPY ./dist/*.deb /tmp/
RUN apt-get install -y /tmp/tedge-snap-plugin*.deb \
    && rm -f /tmp/*.deb

RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

CMD ["/lib/systemd/systemd"]
