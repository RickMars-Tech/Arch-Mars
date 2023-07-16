#!/bin/bash

# Antes de usarlo, ten en cuenta que esta es la forma en la que yo configuro mi sistema.
# Personalízalo a tu gusto para evitar errores.

# Define variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

# Verificar si fwupd está instalado
if ! command -v fwupdmgr &> /dev/null; then
    echo "fwupd no está instalado. Instalando..."
    sudo pacman -Syu --noconfirm fwupd
else
    echo "fwupd está instalado."
fi

echo "Actualizando paquetes y firmware"
sudo pacman -Syyu --noconfirm
fwupdmgr get-devices
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update

# Agregar repo de Chaotic-Aur
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null
echo -e "Se ha configurado Chaotic-Aur"

# Checar si paru está instalado
if command -v paru >/dev/null; then
  echo "Paru $(paru -V | awk '{print $2}') is already installed in your system"
else
  if command -v yay >/dev/null; then
    echo "Yay $(yay -V | awk '{print $2}') is installed in your system"
  else
    echo "Neither Paru nor Yay is present in your system."
    echo "Installing Paru..."
    git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm && cd ..
  fi
fi

# Actualizar el sistema antes de proceder
printf "${YELLOW} Actualización del sistema para evitar problemas\n"
sudo pacman -Sy --noconfirm && sudo powerpill -Su --noconfirm && paru -Su --noconfirm 2>&1 | tee -a "$LOG"

# Activar Repositorio de Flatpak
sudo pacman -S flatpak

sleep 2

# Instalaciones por Flatpak
echo "Instalando Aplicaciones por Flatpak"
sudo flatpak install -y net.davidotek.pupgui2 com.wps.Office org.mamedev.MAME \
    com.discordapp.Discord com.github.tchx84.Flatseal 

# Instalaciobes de yay
sudo paru -S --noconfirm bashtop-git eww-wayland-git grimblast-git gtklock \
    heroic-games-launcher-bin hyprpicker-git nwg-look-bin otf-sora pamac-aur \
    playerctl-git rofi-lbonn-wayland-git sddm-git timeshift ttf-comfortaa \
    ttf-icomoon-feather viewnior-git waybar-hyprland-git wlogout

# Instalaciones por Pacman
echo "Instalando Herramientas por Pacman"
sudo pacman -Syu --needed --noconfirm acpi alsa-lib alsa-plugins bashtop \
    bluez brightnessctl dunst ffmpeg ffmpegthumbnailer firefox gamemode \
    gedit giflib gnome-bluetooth-3.0 gnome-disk-utility gnutls gjs gimp \
    gst-plugins-base-libs gtk3 hyprland hyprpaper imv inotify-tools jdk-openjdk \
    jq kitty kvantum lib32-alsa-lib lib32-alsa-plugins lib32-giflib lib32-gnutls \
    qt5ct lib32-gpg-error lib32-gst-plugins-base-libs lib32-libjpeg-turbo \
    lib32-libldap lib32-libpng lib32-libxcomposite lib32-libxinerama lib32-mesa \
    lib32-mpg123 lib32-ncurses lib32-openal lib32-ocl-icd lib32-sqlite lib32-v4l-utils \
    lib32-va lib32-vulkan-icd-loader lib32-vulkan-radeon libgpg-error libjpeg-turbo \
    libldap libpng libpulse libxcomposite libxinerama libxslt libva libvulkan-icd-loader \
    libvulkan-radeon libxwayland lutris lxappearance mpv ncurses nautilus networkmanager \
    neovim neofetch nm-connection-editor noise-suppression-for-voice ocl-icd openal pamixer \
    papirus-icon-theme pavucontrol polkit-gnome puma-dev qt5-wayland qt5ct \
    qt6-wayland qemu-full ranger rofi socat sqlite steam thunderbird tumbler upower \
    v4l-utils virt-manager vulkan-icd-loader wayland wf-recorder winetricks \
    wl-clipboard xorg-xwayland xdg-desktop-portal-hyprland zsh

# Recargar Fuentes
fc-cache -vf

# Moviendo "cosas"
printf " Copiando archivos de configuracion...\n"
cp -r dotconfig/config/eww/ ~/.config/
cp -r dotconfig/config/gtklock/ ~/.config/
cp -r dotconfig/config/hypr/ ~/.config/ 
cp -r dotconfig/config/kitty/ ~/.config/
cp -r dotconfig/config/mpv/ ~/.config/
cp -r dotconfig/config/neofetch/ ~/.config/
cp -r dotconfig/config/rofi/ ~/.config/
cp -r dotconfig/config/user-dirs.dirs ~/.config/

printf " Copiando archivos extra...\n"
sudo cp -r applications/ ~/.local/share/
sudo cp -r wal/ ~/wal/

printf " Dando permisos a archivos...\n"
chmod +x ~/.config/hypr/xdg-portal-hyprland
chmod +x ~/.config/hypr/minimize-steam
chmod +x ~/.config/hypr/gamemode.sh
# Scripts de eww
chmod +x ~/.config/eww/scripts/apps
chmod +x ~/.config/eww/scripts/bluetooth
chmod +x ~/.config/eww/scripts/brightness
chmod +x ~/.config/eww/scripts/events
chmod +x ~/.config/eww/scripts/hyprland
chmod +x ~/.config/eww/scripts/init
chmod +x ~/.config/eww/scripts/launcher
chmod +x ~/.config/eww/scripts/network
chmod +x ~/.config/eww/scripts/night_light
chmod +x ~/.config/eww/scripts/notifications
chmod +x ~/.config/eww/scripts/osd
chmod +x ~/.config/eww/scripts/player
chmod +x ~/.config/eww/scripts/power
chmod +x ~/.config/eww/scripts/theme
chmod +x ~/.config/eww/scripts/volume
chmod +x ~/.config/eww/scripts/weather

#~~ ZRAM-GENERATOR

# 0/Verificar módulo de zram
if sudo grep -q "^[zram0]$" /etc/systemd/zram-generator.conf; then
    echo "[zram0] ya está configurado en zstd"
else
    # Agregar "[zram0]" al final del archivo
    echo "[zram0]" | sudo tee -a /etc/systemd/zram-generator.conf > /dev/null
    echo -e "El módulo [zram0] se ha establecido"
fi

# 1/Verificar tamaño de zram
if sudo grep -q "^zram-size = ram / 2$" /etc/systemd/zram-generator.conf; then
    echo "compression-algorithm ya está configurado en zstd"
else
    # Agregar "zram-size = ram / 2" al final del archivo
    echo "zram-size = ram / 2" | sudo tee -a /etc/systemd/zram-generator.conf > /dev/null
    echo -e "El tamaño se ha configurado"
fi

# 2/Verificar algoritmo de compresión de zram
if sudo grep -q "^compression-algorithm = zstd$" /etc/systemd/zram-generator.conf; then
    echo "compression-algorithm ya está configurado en zstd"
else
    # Agregar "compression-algorithm = zstd" al final del archivo
    echo "compression-algorithm = zstd" | sudo tee -a /etc/systemd/zram-generator.conf > /dev/null
    echo -e "compression-algorithm se ha configurado en zstd"
fi

# 3/Verificar la prioridad de zram
if sudo grep -q "^swap-priority = 100$" /etc/systemd/zram-generator.conf; then
    echo "swap-priority ya está configurado"
else
    # Agregar "swap-priority = 100" al final del archivo
    echo "swap-priority = 100" | sudo tee -a /etc/systemd/zram-generator.conf > /dev/null
    echo -e "swap-priority se ha configurado en zstd"
fi

# 4/Verificar fs-type
if sudo grep -q "^fs-type = swap$" /etc/systemd/zram-generator.conf; then
    echo "fs-type ya está configurado en zstd"
else
    # Agregar "fs-type = swap" al final del archivo
    echo "fs-type = swap" | sudo tee -a /etc/systemd/zram-generator.conf > /dev/null
    echo -e "fs-type se ha configurado en zstd"
fi

# Optimizaciones de VM (Memoria Virtual)
echo -e "vm.max_map_count=1048576
vm.swappiness=5" | sudo tee -a /etc/sysctl.d/90-override.conf > /dev/null

#~~ KERNEL

# Definir las variables que quieres establecer en el Kernel
options="quiet splash loglevel=3 mitigations=auto,nosmt amd_iommu=on transparent_hugepage=always"

# Ruta del archivo de configuración de GRUB
grub_config="/etc/default/grub"

# Verificar si el archivo de configuración existe
if [ -f "$grub_config" ]; then
  # Comprobar si la variable ya está configurada
  if sudo grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" "$grub_config"; then
    # Actualizar la configuración existente
    sudo sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$options\"/" "$grub_config"
  else
    # Agregar la configuración al final del archivo
    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"$options\"" | sudo tee -a "$grub_config" > /dev/null
  fi

  # Actualizar el archivo de configuración de GRUB
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  echo "La configuración de GRUB ha sido actualizada."
else
  echo "El archivo de configuración de GRUB no se encontró."
fi

sleep 2

# Instalando tema de Sddm
printf " Instalando tema de Sddm...\n"
cp -r sddm/Elegant/ /usr/share/sddm/themes/
sudo sed -i "s/^Current=.*/Current=Elegant/g" /etc/sddm.conf
echo "El tema ha sido instalado correctamente."

sleep 3

# Habilitar sddm
sudo systemctl enable sddm
