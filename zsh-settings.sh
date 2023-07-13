#!/usr/bin/bash

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
  echo "La instalación de Oh My Zsh falló. No se clonarán los plugins."
fi
