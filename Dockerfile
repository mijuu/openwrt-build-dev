# Use Debian 12 as the base image
FROM debian:12

LABEL maintainer=raymond.liang@outlook.com
# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
# Default time zone (can be overridden by environment variable)
ENV TZ=Asia/Shanghai

# Install all required packages for OpenWrt build environment
RUN apt-get update && \
    apt-get install -y \
    build-essential clang flex bison g++ gawk \
    gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev libelf-dev \
    python3-setuptools python3-pyelftools python3-dev rsync swig unzip zlib1g-dev file wget \
    sudo zsh vim openssh-server tzdata \
    && apt-get clean

# Set the time zone using environment variable
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create openwrt user and set up SSH access
RUN useradd -m -s /bin/zsh openwrt && \
    echo "openwrt:openwrt" | chpasswd && \
    usermod -aG sudo openwrt && \
    echo "openwrt ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set openwrt user as the default
USER openwrt
WORKDIR /home/openwrt

# Install Oh My Zsh for better Zsh experience
RUN sudo -u openwrt sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" --unattended

# Setup SSH server
RUN sudo mkdir /var/run/sshd && \
    ssh-keygen -A && \  
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# Start SSH server by default
CMD ["sudo", "/usr/sbin/sshd", "-D"]
