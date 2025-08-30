FROM ubuntu:latest
RUN sudo apt update || apt update
RUN sudo apt install -y sudo || apt install -y sudo
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC sudo apt-get -y install tzdata
RUN sudo apt install -y software-properties-common
RUN sudo add-apt-repository ppa:mozillateam/ppa
RUN sudo apt install -y adb
RUN sudo apt install -y bind9-host
RUN sudo apt install -y curl
RUN sudo apt install -y dbus
RUN sudo apt install -y dbus-x11
RUN sudo apt install -y dnsutils
RUN sudo apt install -y firefox-esr
RUN sudo apt install -y git
RUN sudo apt install -y gpg
RUN sudo apt install -y iproute2
RUN sudo apt install -y iputils-ping
RUN sudo apt install -y lsb-release
RUN sudo apt install -y lsof
RUN sudo apt install -y nano
RUN sudo apt install -y net-tools
RUN sudo apt install -y openssh-client
RUN sudo apt install -y openssh-server
RUN sudo apt install -y passwd
RUN sudo apt install -y python3
RUN sudo apt install -y scrcpy
RUN sudo apt install -y squid
RUN sudo apt install -y sudo
RUN sudo apt install -y systemd
RUN sudo apt install -y systemd-sysv
RUN sudo apt install -y tigervnc-common
RUN sudo apt install -y tigervnc-standalone-server
RUN sudo apt install -y tightvncserver
RUN sudo apt install -y tmate
RUN sudo apt install -y tmux
RUN sudo apt install -y unzip
RUN sudo apt install -y wget
RUN sudo apt install -y x11vnc
RUN sudo apt install -y xfce4
RUN sudo apt install -y xfce4-goodies
RUN sudo apt install -y xfce4-session
RUN sudo apt install -y xxd
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
RUN ( ( echo $$ > ~/tmp_vnc_pid.txt ; ~/novnc/utils/novnc_proxy )&) && while sleep 0.1 ; do curl -sS 127.0.0.1:6080 && break ; done && kill "$(cat ~/tmp_vnc_pid.txt)"
RUN mkdir -p ~/.ssh/
RUN sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox-esr 999
RUN update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal.wrapper 999
RUN mkfifo ~/runner_console
COPY . .
RUN $(: LOCAL_ONLY ) ./to_be_launched_in_runner.sh
