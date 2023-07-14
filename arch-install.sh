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

# Checar si paru está instalado
if command -v paru &>/dev/null; then
  echo "Paru $(paru -V | awk '{print $2}') is already installed in your system"
else
  if command -v yay &>/dev/null; then
    echo "Yay $(yay -V | awk '{print $2}') is installed in your system"
  else
    echo "Neither Paru nor Yay is present in your system."
    echo "Installing Paru..."
    git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm && cd ..
  fi
fi

# Actualizar el sistema antes de proceder
printf "${YELLOW} Actualización del sistema para evitar problemas\n"
yay -Syu --noconfirm 2>&1 | tee -a "$LOG"

# Activar Repositorio de Flatpak
sudo pacman -S flatpak

sleep 2

# Instalaciones por Flatpak
echo "Instalando Aplicaciones por Flatpak"
flatpak install -y net.davidotek.pupgui2 com.wps.Office org.mamedev.MAME \
    com.discordapp.Discord com.github.tchx84.Flatseal 

# Instalaciobes de yay
paru -S waybar-hyprland-git hyprpicker-git eww-wayland-git grimblast-git \
    wlogout viewnior-git playerctl-git pamac-aur bashtop-git timeshift \
    gtklock nwg-look-bin otf-sora heroic-games-launcher ttf-icomoon-feather \
    ttf-comfortaa rofi-lbonn-wayland-git lightdm-webkit-theme-aether

# Instalaciones por Pacman
echo "Instalando Herramientas por Pacman"
sudo pacman -Syu --needed --noconfirm hyprland xdg-desktop-portal-hyprland \
    kitty neofetch thunderbird steam lutris rofi ffmpeg neovim zsh mpv imv \
    ffmpegthumbnailer virt-manager pavucontrol nautilus gimp hyprpaper\
    qemu-full wl-clipboard wf-recorder brightnessctl tumbler ranger \
    ttf-daddytime-mono-nerd noise-suppression-for-voice pamixer upower \
    qt5-wayland qt6-wayland wayland alsa-utils inotify-tools gjs socat acpi \
    gedit bashtop dunst gnome-disk-utility gamemode winetricks \
    firefox lightdm lightdm-gtk-greeter wine-staging giflib lib32-giflib \
    libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 \
    lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse \
    lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins \
    lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-mesa \
    lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite vulkan-radeon \
    libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses \
    lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva \
    lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-libxcomposite \
    lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader \
    lib32-vulkan-radeon polkit-gnome papirus-icon-theme

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
sudo cp -r applications/ /home/rick/.local/share/
sudo cp -r wal/ /opt/

printf " Dando permisos a archivos...\n"
chmod +x ~/.config/hypr/xdg-portal-hyprland
chmod +x ~/.config/hypr/minimize-steam
chmod +x ~/.config/hypr/gamemode.sh
chmod +x ~/.config/eww/scripts/init

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
echo -e "vm.max_map_count=1048576\nvm.swappiness=5\nnet.ipv4.tcp_timestamps = 0\nnet.ipv4.tcp_sack = 1\nnet.ipv4.tcp_no_metrics_save = 1\n#### Escalando TCP ####\nnet.ipv4.tcp_window_scaling = 1" | sudo tee -a /etc/sysctl.d/90-override.conf > /dev/null

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

# Habilitar sddm
sudo systemctl enable lightdm
