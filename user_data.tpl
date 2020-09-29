#!/usr/bin/env bash

cd /tmp
echo "Running yum update"
sudo yum update -y

echo "Installing Development Tools"
sudo yum group install -y "Development Tools"

echo "Installing dependent packages"
sudo yum install -y tigervnc-server openssl-devel pam-devel fuse-devel pixman-devel nasm libX11-devel libXfixes-devel libXrandr-devel
sudo yum install -y xterm gnome-shell gnome-session nautilus

echo "Downloading xrdp"
wget https://github.com/neutrinolabs/xrdp/releases/download/v0.9.11/xrdp-0.9.11.tar.gz

echo "Untarring xrdp"
tar zxvf xrdp-0.9.11.tar.gz

echo "making xrdp"
cd xrdp-0.9.11
./configure --prefix=/opt/xrdp \
            --sysconfdir=/etc  \
            --enable-fuse      \
            --enable-pixman    \
            --enable-painter   \
            --with-systemdsystemunitdir=/usr/lib/systemd/system 
make V=0
sudo make install

echo "Downloading config files"
sudo wget -q http://artifacts.wwtlab.net/config-files/xrdp/startwm.sh -O /etc/xrdp/startwm.sh
sudo wget -q http://artifacts.wwtlab.net/config-files/xrdp/xrdp.ini -O /etc/xrdp/xrdp.ini

echo "Starting xrdp process"
sudo systemctl enable --now xrdp

# Creating User Account
echo "Creating User Account"
adduser ${username}

# Installing Terminal
echo "Installing Terminal"
sudo yum -y install gnome-terminal
sudo yum -y install dejavu-sans-mono-fonts

# Installing Chromium
echo "Installing Chromium"
sudo amazon-linux-extras install epel
sudo yum -y install chromium
sudo sed -i 's#Exec=/usr/bin/chromium-browser#Exec=/usr/bin/chromium-browser --password-store=basic#g' /usr/share/applications/chromium-browser.desktop

# Installing VS Code
echo "Installing Visual Studio Code"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo yum -y check-update
sudo yum -y install code

# Installing Docker
echo "Installing Docker"
sudo yum install docker -y
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker ${username}

# Setting up desktop
echo "Setting up user desktop"
sudo su -c "dbus-launch gsettings set org.gnome.desktop.background show-desktop-icons true" -s /bin/bash ${username}
sudo su -c "dbus-launch gsettings set org.gnome.desktop.lockdown disable-lock-screen true" -s /bin/bash ${username}
sudo su -c "dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false" -s /bin/bash ${username}
sudo su -c "dbus-launch gsettings set org.gnome.desktop.screensaver idle-activation-enabled false" -s /bin/bash ${username}
sudo su -c "dbus-launch gsettings set org.gnome.desktop.session idle-delay 0" -s /bin/bash ${username}

# Adding Icons
echo "Adding Desktop Icons"
sudo mkdir /home/${username}/Desktop
sudo chown -R ${username}:${username} /home/${username}/Desktop

sudo su -c "cp /usr/share/applications/org.gnome.Terminal.desktop /home/${username}/Desktop/Terminal.desktop" -s /bin/bash ${username}
sudo su -c "chown ${username}:${username} /home/${username}/Desktop/Terminal.desktop" -s /bin/bash ${username}
sudo su -c "dbus-launch gio set /home/${username}/Desktop/Terminal.desktop metadata::trusted yes" -s /bin/bash ${username}

sudo su -c "cp /usr/share/applications/chromium-browser.desktop /home/${username}/Desktop/Chromium.desktop" -s /bin/bash ${username}
sudo su -c "chown ${username}:${username} /home/${username}/Desktop/Chromium.desktop" -s /bin/bash ${username}
sudo su -c "dbus-launch gio set /home/${username}/Desktop/Chromium.desktop metadata::trusted yes" -s /bin/bash ${username}

sudo su -c "sudo cp /usr/share/applications/code.desktop /home/${username}/Desktop/VS\ Code.desktop" -s /bin/bash ${username}
sudo su -c "chown ${username}:${username} /home/${username}/Desktop/VS\ Code.desktop" -s /bin/bash ${username}
sudo su -c "dbus-launch gio set /home/${username}/Desktop/VS\ Code.desktop metadata::trusted yes" -s /bin/bash ${username}

## Setting Hostname
hostnamectl set-hostname ${name_prefix}jumpbox

## Setting User Password
echo -e "${password}\n${password}" | passwd ${username}

${user_data}