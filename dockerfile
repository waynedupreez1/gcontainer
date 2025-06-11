FROM docker.io/ubuntu:24.04
LABEL maintainer="Wayne du Preez (waynedupreez1@gmail.com)"
ARG tz="Pacific/Auckland"

USER root:root

# Configure default user and set env
ENV PUID=1000 \
    PGID=1000 \
    USER="gaming" \
    USER_PASSWORD="password" \
    USER_HOME="/home/gaming" \
    TZ=${tz} \
    USER_LOCALES="en_US.UTF-8 UTF-8" \
    container=docker

# Install core packages
RUN apt-get update && \
    apt-get upgrade && \
    dpkg --add-architecture i386 && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        apt-utils \
        gpg-agent \
        apt-transport-https \
        keyboard-configuration \
        locales && \
    apt-get clean autoclean -y && \
    apt-get autoremove -y

# Configure Locales
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen

# Install common packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        bash-completion \
        curl \
        git \
        less \
        sudo \
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
        bzip2 \
        execline

# Install Graphics/Audio
RUN apt-get update && \
    add-apt-repository ppa:kisak/kisak-mesa && \
    apt-get install -y --no-install-recommends \
        xserver-xorg \
        xserver-xorg-video-dummy \
        xinit \
        x11-xserver-utils \
        x11-apps \
        dbus-x11 \
        i965-va-driver-shaders \
        vainfo \
        mesa-utils \
        vulkan-tools \
        libvulkan1 \
        pulseaudio \
        alsa-utils \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-bad1.0-dev \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
        gstreamer1.0-tools \
        gstreamer1.0-x \
        gstreamer1.0-alsa \
        gstreamer1.0-gl \
        gstreamer1.0-gtk3 \
        gstreamer1.0-qt5 \
        gstreamer1.0-pulseaudio && \
    apt-get clean autoclean -y && \
    apt-get autoremove -y

#Install XFCE and terminal
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 \
        libxfce4ui-utils \
        thunar \
        xfce4-appfinder \
        xfce4-panel \
        xfce4-session \
        xfce4-settings \
        xfce4-terminal \
        xfconf \
        xfdesktop4 \
        xfwm4 && \
    apt-get clean autoclean -y && \
    apt-get autoremove -y

# Install Wintricks/Wine
RUN curl -s https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/winehq.gpg > /dev/null && \
    echo deb [signed-by=/usr/share/keyrings/winehq.gpg] http://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main | sudo tee /etc/apt/sources.list.d/winehq.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        winehq-stable \
        winetricks && \
    apt-get clean autoclean -y && \
    apt-get autoremove -y

# Install Lutris
ENV LUTRIS_VERSION="0.5.18"
ARG LUTRIS_ROOT=/tmp/lutris.deb
RUN curl -# -L -o ${LUTRIS_ROOT} https://github.com/lutris/lutris/releases/download/v${LUTRIS_VERSION}/lutris_${LUTRIS_VERSION}_all.deb && \
    apt-get update && \   
    apt-get install -y --no-install-recommends \
        ${LUTRIS_ROOT} && \
    apt-get clean autoclean -y && \
    apt-get autoremove -y

# Install/Config and Start Sunshine
ARG SUNSHINE_ROOT=/tmp/sunshine.deb
RUN curl -# -L -o ${SUNSHINE_ROOT} https://github.com/LizardByte/Sunshine/releases/download/v2025.122.141614/sunshine-ubuntu-24.04-amd64.deb && \
    apt-get update && \   
    apt-get install -y --no-install-recommends \
        ${SUNSHINE_ROOT} && \
    apt-get clean autoclean -y && \
    apt-get autoremove -y

#Remove existing user ubuntu and create new user
RUN userdel -r ubuntu && \
    useradd -m -u ${PUID} -d ${USER_HOME} -s /bin/bash ${USER} && \
    chown -R ${USER} ${USER_HOME} && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 

# Set display environment variables
ENV DISPLAY_CDEPTH="24" \
    DISPLAY_DPI="96" \
    DISPLAY_REFRESH="60" \
    DISPLAY_SIZEH="1080" \
    DISPLAY_SIZEW="1920" \
    DISPLAY_VIDEO_PORT="DFP" \
    DISPLAY=":0" \
    NVIDIA_DRIVER_CAPABILITIES="all" \
    NVIDIA_VISIBLE_DEVICES="all" \
    XORG_SOCKET_DIR="/tmp/.X11-unix" \
    XDG_RUNTIME_DIR="/tmp/.X11-unix/run"

# Set pulseaudio environment variables
ENV PULSE_SOCKET_DIR="/tmp/pulse" \
    PULSE_SERVER="unix:/tmp/pulse/pulse-socket"

# Set container configuration environment variables
ENV MODE="primary" \
    WEB_UI_MODE="vnc" \
    ENABLE_VNC_AUDIO="true" \
    ENABLE_SUNSHINE="true" \
    ENABLE_EVDEV_INPUTS="true"

#Install PID 1 supervisor
ARG S6_OVERLAY_VERSION=3.2.1.0
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

#Add services to run via supervisor
#COPY supervisor/ /etc/s6-overlay/s6-rc.d/

#Copy fake monitor configs
COPY 10_dummy_1920x1080.conf /etc/X11/xorg.conf.d/

RUN rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# Set entrypoint
ENTRYPOINT ["/init"]
