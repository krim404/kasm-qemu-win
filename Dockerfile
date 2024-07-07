FROM kasmweb/core-ubuntu-jammy:1.15.0

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

USER root

RUN set -eu && \
    apt-get update \
    && apt-get upgrade -y
	
RUN apt-get --no-install-recommends -y install \
        tini \
        wget \
        ovmf \
		bc \
		wsdd \
		samba \
		xz-utils \
		wimtools \
		dos2unix \
		cabextract \
		genisoimage \
		libxml2-utils \
        swtpm \
        procps \
        iptables \
        iproute2 \
        apt-utils \
        dnsmasq \
        net-tools \
        qemu-utils \
        ca-certificates \
        netcat-openbsd \
        qemu-system-x86 \
        qemu-system-gui \
        sudo \
		p7zip-full \
        mpg123 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./src /run/
COPY ./qemu.desktop /etc/xdg/autostart/qemu.desktop

RUN chmod +x /run/*.sh
#RUN echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers <-- not needed now... Will be relevant later maybe, when container does not need root

RUN mkdir /storage
VOLUME /storage
RUN chown -R 1000:1000 /storage

ENV RAM_SIZE "8G"
ENV CPU_CORES "2"
ENV DISK_SIZE "64G"
ENV VERSION "win11"

ARG VERSION_ARG="0.0"
RUN echo "$VERSION_ARG" > /run/version

COPY --chmod=664 ./virtio-win-0.1.248.tar.xz /drivers.txz
COPY --chmod=755 ./wsdd.py /usr/sbin/wsdd

# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
#RUN cp /usr/share/backgrounds/bg_kasm.png /usr/share/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel

ENV QEMUDISPLAY "gtk,full-screen=on"

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
