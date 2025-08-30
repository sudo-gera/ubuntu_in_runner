FROM ubuntu:latest
RUN sudo -E apt update || apt update
RUN sudo -E apt install -y sudo || apt install -y sudo
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC sudo -E apt-get -y install tzdata
RUN sudo -E apt install -y software-properties-common
RUN sudo -E add-apt-repository ppa:mozillateam/ppa
RUN sudo -E apt install -y adb
RUN sudo -E apt install -y bind9-host
RUN sudo -E apt install -y curl
RUN sudo -E apt install -y dbus
RUN sudo -E apt install -y dbus-x11
RUN sudo -E apt install -y dnsutils
RUN sudo -E apt install -y firefox-esr
RUN sudo -E apt install -y git
RUN sudo -E apt install -y gpg
RUN sudo -E apt install -y iproute2
RUN sudo -E apt install -y iputils-ping
RUN sudo -E apt install -y lsb-release
RUN sudo -E apt install -y lsof
RUN sudo -E apt install -y nano
RUN sudo -E apt install -y net-tools
RUN sudo -E apt install -y openssh-client
RUN sudo -E apt install -y openssh-server
RUN sudo -E apt install -y passwd
RUN sudo -E apt install -y python3
RUN sudo -E apt install -y scrcpy
RUN sudo -E apt install -y squid
RUN sudo -E apt install -y sudo -E
RUN sudo -E apt install -y systemd
RUN sudo -E apt install -y systemd-sysv
RUN sudo -E apt install -y tigervnc-common
RUN sudo -E apt install -y tigervnc-standalone-server
RUN sudo -E apt install -y tightvncserver
RUN sudo -E apt install -y tmate
RUN sudo -E apt install -y tmux
RUN sudo -E apt install -y unzip
RUN sudo -E apt install -y wget
RUN sudo -E apt install -y x11vnc
RUN sudo -E apt install -y xfce4
RUN sudo -E apt install -y xfce4-goodies
RUN sudo -E apt install -y xfce4-session
RUN sudo -E apt install -y xxd
RUN sudo -E apt install -y bash
RUN mkdir -p ~/.vnc/
RUN echo | vncpasswd -f | tee ~/.vnc/passwd > /dev/null
RUN chmod 600 ~/.vnc/passwd
RUN touch ~/.Xauthority
RUN echo 'unset SESSION_MANAGER' | tee -a ~/.vnc/xstartup > /dev/null
RUN echo 'unset DBUS_SESSION_BUS_ADDRESS' | tee -a ~/.vnc/xstartup > /dev/null
RUN echo 'startxfce4' | tee -a ~/.vnc/xstartup > /dev/null
RUN chmod +x ~/.vnc/xstartup
RUN curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.6.0.zip -o ~/novnc.zip
RUN unzip ~/novnc.zip
RUN mv ./noVNC* ~/novnc
RUN printf '%s\\n' 'export USER=$(whoami)' | tee -a ~/.bashrc > /dev/null
RUN ( bash -c 'echo $$ > ~/tmp_vnc_pid.txt ; ~/novnc/utils/novnc_proxy' &) && while sleep 0.1 ; do curl -sS 127.0.0.1:6080 && break ; done && kill "$(cat ~/tmp_vnc_pid.txt)"
RUN mkdir -p ~/.ssh/
RUN sudo -E update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox-esr 999
RUN update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal.wrapper 999
RUN mkfifo ~/runner_console
RUN printf '%s\n' 'set -g default-terminal "xterm-color"' >> ~/.tmux.conf
RUN sudo -E sed -i 's?\bdeny\b?allow?g' /etc/squid/squid.conf
COPY . .
RUN $(: LOCAL_ONLY ) ./to_be_launched_in_runner.sh
