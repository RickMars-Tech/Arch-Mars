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
  echo "Paru $(paru -V | awk '{print $2}') is already installed in your system"
else
  if command -v yay >/dev/null; then
    echo "Yay $(yay -V | awk '{print $2}') is installed in your system"
  else
    echo "Neither Paru nor Yay is present in your system."
    echo "Installing Paru..."
    git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si && cd ..
  fi
fi

sleep 3

# Actualizar el sistema antes de proceder
printf "${YELLOW} Actualización del sistema para evitar problemas\n"
paru 2>&1 | tee -a "$LOG"

sleep 2

# Activar Repositorio de Flatpak
sudo pacman -S flatpak

sleep 2

# Instalaciones por Flatpak
echo "Instalando Aplicaciones por Flatpak"
sudo flatpak install -y net.davidotek.pupgui2 org.mamedev.MAME com.discordapp.Discord com.github.tchx84.Flatseal \
    com.usebottles.bottles org.onlyoffice.desktopeditors io.github.mgerhardy.vengi.voxedit \
    net.veloren.airshipper 2>&1 | tee -a "$LOG"

# Instalacion de herramientas
echo "Instalando Herramientas y Aplicaciones"
paru -S archlinux-tweak-tool-git bashtop-git bottles eww-wayland gtklock hyprpicker-git pamac-aur powerpill playerctl-git \
    sddm sddm-sugar-dark sddm-sugar-candy-git sddm-elegant-theme-git sddm-slice-git otf-font-awesome nerd-fonts-sf-mono \
    otf-nerd-fonts-monacob-mono gotop-bin acpi alsa-lib adobe-source-han-sans-kr-fonts bcache-tools ttf-daddytime-mono-nerd \
    stacer-bin alsa-plugins bat bluez brightnessctl cups dunst ffmpeg ffmpegthumbnailer vapoursynth gamemode gamescope-plus gedit \
    geforcenow-electron giflib gnome-bluetooth-3.0 gnome-disk-utility gnutls gjs firefox gst-plugins-base-libs gimp grim gtk3 hyprland \
    hyprpaper imv inotify-tools jre17-openjdk jq kitty kvantum libadwaita lib32-alsa-lib lib32-alsa-plugins lib32-giflib \
    lib32-gnutls qt5ct lib32-gamemode lib32-gst-plugins-base-libs lib32-libjpeg-turbo adobe-source-han-sans-jp-fonts lib32-libldap \
    lib32-libpng lib32-libxcomposite lib32-libxinerama lib32-mesa lib32-mpg123 lib32-ncurses lib32-openal lib32-ocl-icd lib32-sqlite \
    lib32-v4l-utils lib32-vulkan-icd-loader lib32-vulkan-radeon libgpg-error libjpeg-turbo libldap libpng libpulse libxcomposite \
    libxinerama libxslt libva lutris lxappearance mouse_m908 mpv ncurses nautilus nawk networkmanager neovim neofetch android-udev \
    nm-connection-editor noise-suppression-for-voice ocl-icd openal pamixer papirus-icon-theme pavucontrol polkit-gnome python \
    qt5-wayland qt5ct qt6-wayland ranger rife-ncnn-vulkan rofi swww socat sqlite slurp steam swappy thunderbird tumbler ufw upower \
    v4l-utils virt-manager vulkan-icd-loader vulkan-radeon wayland wf-recorder wine-staging winetricks wl-clipboard xorg-xwayland \
    xdg-desktop-portal-hyprland xfsprogs zsh zsh-autosuggestions-git zsh-fast-syntax-highlighting-git 2>&1 | tee -a "$LOG"
    
# Recargar Fuentes
fc-cache -vf
echo -e "Se han recargado las fuentes del Sistema..."

sleep 3

# Configuracion de ufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sleep 3
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo -e "Se han configurado las reglas del Firmware..."

sleep 3

# Moviendo "cosas"
printf " Copiando archivos de configuracion...\n"
cp -r dotconfig/config/* ~/.config/ 2>&1 | tee -a "$LOG"

printf " Copiando archivos extra...\n"
cp -r applications/ ~/.local/share/ 2>&1 | tee -a "$LOG"
cp -r dotconfig/wal/ ~/ 2>&1 | tee -a "$LOG"
cp -r SKLauncher/ ~/ 2>&1 | tee -a "$LOG"
cp -r dotconfig/.gtkrc-2.0 ~/

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

sleep 4

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

sleep 4

#~~ Gamescope
echo -e "Estableciendo prioridad de Gamescope..."
setcap 'CAP_SYS_NICE=eip' "$(command -v gamescope)"

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

sleep 3

# Habilitar sddm
sudo systemctl enable sddm
