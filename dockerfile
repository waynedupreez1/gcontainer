FROM docker.io/ubuntu:24.04
LABEL maintainer="Wayne du Preez (waynedupreez1@gmail.com)"
ARG tz="Pacific/Auckland"

# Configure default user and set env
ENV \
    PUID=1000 \
    PGID=1000 \
    USER="gaming" \
    USER_PASSWORD="password" \
    USER_HOME="/home/gaming" \
    TZ=${tz} \
    USER_LOCALES="en_US.UTF-8 UTF-8"

# Install core packages
RUN \
    echo "**** Install tools and configure process ****" \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
            software-properties-common \
            apt-utils \
			gpg-agent \
			locales \
		&& dpkg --add-architecture i386 \
	    && echo "**** Install and configure locals ****" \
        && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
        && locale-gen \
        && apt-get clean autoclean -y \
        && apt-get autoremove -y \
        && rm -rf \
            /var/lib/apt/lists/* \
            /var/tmp/* \
            /tmp/*
RUN \
    echo "**** Install common packages ****" \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
            bash \
            bash-completion \
            curl \
            git \
            less \
            nano \
            net-tools \
            patch \
            pciutils \
            pkg-config \
            procps \
            sudo \
            unzip \
            p7zip-full \
            wget \
            xz-utils \
			ffmpeg \
            fuse \
            libfuse2

RUN \
    echo "**** Install graphics drivers ****" \
        && add-apt-repository ppa:kisak/kisak-mesa \
        && apt-get update \
        && apt-get install -y --no-install-recommends \           
# Mesa packages
            mesa-utils \
# Vulkan packages
            vulkan-tools \
            libvulkan1 \
# Desktop environment
            ubuntu-mate-desktop \
# Install audio requirements
            pulseaudio \
            alsa-utils \
# Install audio support
            bzip2 \
            gstreamer1.0-alsa \
            gstreamer1.0-gl \
            gstreamer1.0-gtk3 \
            gstreamer1.0-libav \
            gstreamer1.0-plugins-bad \
            gstreamer1.0-plugins-base \
            gstreamer1.0-plugins-good \
            gstreamer1.0-plugins-ugly \
            gstreamer1.0-pulseaudio \
            gstreamer1.0-qt5 \
            gstreamer1.0-tools \
            gstreamer1.0-vaapi \
            gstreamer1.0-x \
            libgstreamer1.0-0 \
            libopenal1 \
            libsdl-image1.2 \
            libsdl-ttf2.0-0 \
            libsdl1.2debian \
            libsndfile1 \
            ucspi-tcp \
        && apt-get clean autoclean -y \
        && apt-get autoremove -y \
        && rm -rf \
            /var/lib/apt/lists/* \
            /var/tmp/* \
            /tmp/*

VOLUME /home/${USER}/	

# Install Lutris/Wine
RUN \
    echo "**** Install Lutris/Wine ****" \
		&& add-apt-repository -y ppa:lutris-team/lutris \
		&& apt-get update \
        && apt-get install -y \
			wine-stable \
			lutris \
			winetricks

# Install Sunshine
ARG SUNSHINE_VERSION=0.18.4
RUN \
    echo "**** Fetch Sunshine deb package ****" \
        && cd /tmp \
        && wget -O /tmp/sunshine-24.04.deb \
		    https://github.com/LizardByte/Sunshine/releases/download/v${SUNSHINE_VERSION}/sunshine-ubuntu-24.04-amd64.deb \
    && \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install Sunshine ****" \
        && apt-get install -y /tmp/sunshine-22.04.deb \
    && \
    echo "**** Section cleanup ****" \
        && apt-get clean autoclean -y \
        && apt-get autoremove -y \
        && rm -rf \
            /var/lib/apt/lists/* \
            /var/tmp/* \
            /tmp/*
RUN \
    echo "**** Configure default user '${USER}' ****" \
        && mkdir -p \
            ${USER_HOME} \
        && useradd -d ${USER_HOME} -s /bin/bash ${USER} \
        && chown -R ${USER} \
            ${USER_HOME} \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && \
    echo
		
# Set display environment variables
ENV \
    DISPLAY_CDEPTH="24" \
    DISPLAY_DPI="96" \
    DISPLAY_REFRESH="60" \
    DISPLAY_SIZEH="1080" \
    DISPLAY_SIZEW="1920" \
    DISPLAY_VIDEO_PORT="DFP" \
    DISPLAY=":55" \
    NVIDIA_DRIVER_CAPABILITIES="all" \
    NVIDIA_VISIBLE_DEVICES="all" \
    XORG_SOCKET_DIR="/tmp/.X11-unix" \
    XDG_RUNTIME_DIR="/tmp/.X11-unix/run"

# Set pulseaudio environment variables
ENV \
    PULSE_SOCKET_DIR="/tmp/pulse" \
    PULSE_SERVER="unix:/tmp/pulse/pulse-socket"

# Set container configuration environment variables
ENV \
    MODE="primary" \
    WEB_UI_MODE="vnc" \
    ENABLE_VNC_AUDIO="true" \
    ENABLE_SUNSHINE="true" \
    ENABLE_EVDEV_INPUTS="true"

# Configure required ports
ENV \
    PORT_NOVNC_WEB="8083"

# Expose the required ports
EXPOSE 8083

# Set entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]