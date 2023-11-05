#!/bin/bash
# Antes de usarlo, ten en cuenta que esta es la forma en la que yo configuro mi sistema.
# Personalízalo a tu gusto para evitar errores.
if [[ $EUID -eq 0 ]]; then
   echo "Este script no debe ejecutarse con privilegios de administrador"
   exit 1
fi
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

# Actualizar paquetes y firmware
sudo pacman -Syyuu --noconfirm --needed
fwupdmgr get-devices
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update
echo -e "Se han Actualizado paquetes y firmware"

# Checar si paru está instalado
if command -v paru >/dev/null; then
  echo "Paru $(paru -V | awk '{print $2}') ya está instalado en su sistema"
else
  if command -v yay >/dev/null; then
    echo "Yay $(yay -V | awk '{print $2}') está instalado en su sistema"
  else
    echo "Ni Paru ni Yay están presentes en su sistema."
    echo "Installing Paru..."
    git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si && cd ..
  fi
fi

# Actualizar el sistema antes de proceder
printf "${YELLOW} Actualización del sistema para evitar problemas\n"
paru --noconfirm --needed 2>&1 | tee -a "$LOG"

# Activar Repositorio de Flatpak
sudo pacman -S --noconfirm --needed flatpak 2>&1 | tee -a "$LOG"

# Instalaciones por Flatpak
echo "Instalando Aplicaciones por Flatpak"
sudo flatpak install -y net.davidotek.pupgui2 org.mamedev.MAME com.discordapp.Discord \
    com.github.tchx84.Flatseal com.usebottles.bottles org.onlyoffice.desktopeditors   \
    io.github.mgerhardy.vengi.voxedit net.veloren.airshipper 2>&1 | tee -a "$LOG"

# Instalacion de herramientas
echo "Instalando Herramientas y Aplicaciones"
sudo pacman -S alsa-utils zsh ttf-daddytime-mono-nerd ffmpeg ffmpegthumbnailer vapoursynth kitty           \
        lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader gamemode    \
        neovim lib32-gamemode wine-staging wine-gecko wine-mono lib32-alsa-lib lib32-alsa-plugins          \
        pipewire-pulse lib32-libpulse pipewire-alsa lib32-alsa-lib lib32-alsa-plugins lib32-alsa-oss       \
        lib32-gnutls lib32-sdl2 lib32-gst-plugins-base lib32-gst-plugins-base-libs lib32-gst-plugins-good  \
        gst-libav gst-plugins-bad gst-plugins-base lib32-pipewire-jack lib32-pipewire fuse                 \
        gst-plugins-good gst-plugins-ugly gst-plugin-pipewire gstreamer-vaapi gstreamer lib32-openal       \
        libde265 gimp jre17-openjdk neofetch ufw steam lutris firefox pavucontrol-qt mpv lmms winetricks 2>&1 | tee -a "$LOG"

paru -S bottles pamac-aur rife-ncnn-vulkan gst-plugin-openh264 2>&1 | tee -a "$LOG"

# Recargar Fuentes
fc-cache -vf
echo -e "Se han recargado las fuentes del Sistema..."

# Configuracion de ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo -e "Se han configurado las reglas del Firmware..."

# Moviendo "cosas"
printf " Copiando archivos de configuracion...\n"
cp -r dotconfig/config/* ~/.config/ 2>&1 | tee -a "$LOG"

printf " Copiando archivos extra...\n"
cp -r dotconfig/wal/ ~/ 2>&1 | tee -a "$LOG"
cp -r dotconfig/.gtkrc-2.0 ~/ 2>&1 | tee -a "$LOG"

# Pregunta al usuario si desea instalar Hyperland en Arch Linux
read -p "¿Quieres instalar Hyperland en Arch Linux? (s/n): " respuesta

# Comprueba la respuesta del usuario
if [[ $respuesta == "s" || $respuesta == "S" ]]; then
    echo "Iniciando la instalación de Hyperland en Arch Linux..."
paru -S xdg-desktop-portal-hyprland wf-recorder upower swappy slurp nm-connection-editor gtklock kvantum   \
     gtk3 hyprland hyprpaper imv inotify-tools grim gedit dunst brightnessctl sddm-git waybar-hyprland-git \
     acpi playerctl-git hyprpicker-git eww-wayland

printf " Dando permisos a archivos...\n"
chmod +x ~/.config/hypr/scripts/xdg-portal-hyprland
chmod +x ~/.config/hypr/scripts/minimize-steam
chmod +x ~/.config/hypr/scripts/gamemode.sh
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
chmod +x ~/.config/eww/scripts/myshell/myshell
    
    echo "Hyperland ha sido instalado y configurado correctamente."
else
    echo "No se realizará la instalación de Hyperland."
fi

#~~ ZRAM-GENERATOR

# Verificar si zram-generator está instalado
if pacman -Qi zram-generator &> /dev/null; then
    echo "zram-generator ya está instalado."
else
    # Instalar zram-generator si no está instalado
    echo "Instalando zram-generator..."
    sudo pacman -S zram-generator --needed
    echo "zram-generator se ha instalado correctamente."
fi

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

# Verificar si Zsh ya está configurado como el intérprete predeterminado
if [[ $(basename "$SHELL") != "zsh" ]]; then
  # Establecer Zsh como el intérprete predeterminado
  chsh -s "$(which zsh)"
  echo "Zsh se ha configurado como el intérprete de comandos predeterminado."
else
  echo "Zsh ya está configurado como el intérprete de comandos predeterminado."
fi
# Instalar Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Verificar si la instalación de Oh My Zsh se completó correctamente
if [ $? -eq 0 ]; then
  # Clonando los plugins de oh-my-zsh
    # Plugin Autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    # Plugin Fast-Syntax-Highlight
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
    # Copiar directorio de Oh My Zsh
  cp -r dotconfig/oh-my-zsh/eye.zsh-theme ~/.oh-my-zsh/themes/
    # Copiar archivo de configuración Zsh
  cp -r dotconfig/.zshrc ~/
else
  echo "La instalación de Oh My Zsh falló. No se clonarán las configuraciones."
fi

#~~ Gamescope
echo -e "Estableciendo prioridad de Gamescope..."
sudo setcap 'CAP_SYS_NICE=eip' "$(command -v gamescope)" 2>&1 | tee -a "$LOG"

#~~ KERNEL
# Definir las variables que quieres establecer en el Kernel
options="quiet splash loglevel=3 mitigations=auto,nosmt transparent_hugepage=always"
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

# Verificar si SDDM está instalado
if pacman -Qs sddm > /dev/null; then
    echo "SDDM ya está instalado. No se realizarán cambios."
else
    echo "SDDM no está instalado. Instalando..."
    sudo pacman -S sddm --noconfirm

    # Activar el servicio
    echo "Activando el servicio SDDM..."
    sudo systemctl enable sddm
    sudo systemctl start sddm

    echo "SDDM se ha instalado y activado correctamente."
fi
