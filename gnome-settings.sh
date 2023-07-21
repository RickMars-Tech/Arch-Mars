#!/usr/bin/bash
# Utiliza este script solo si usaras Gnome.
if [[ $EUID -eq 0 ]]; then
   echo "Este script no debe ejecutarse con privilegios de administrador"
   exit 1
fi
# Configuraciones de Gnome
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface font-name 'Montserrat'
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.interface clock-show-date false
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.interface enable-hot-corners false
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///home/rick/wal/1920x1080.png'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.shell enabled-extensions "$(gnome-extensions list --user --enabled | awk '{printf("%s,",$1)}' | sed 's/,$//')"

# Optimizaciones de Gnome-Shell
sudo sed -i -e 's/^#ShutdownTimeout=/ShutdownTimeout=/' /etc/PackageKit/PackageKit.conf
systemctl restart packagekit.service
mkdir -pv ~/.config/autostart && cp /usr/share/applications/org.gnome.Software.desktop ~/.config/autostart/
echo "X-GNOME-Autostart-enabled=false" >> ~/.config/autostart/org.gnome.Software.desktop

dconf write /org/gnome/desktop/search-providers/disabled "['org.gnome.Software.desktop']"
