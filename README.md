# ArchMars
Esta es mi configuracion personal de Arch y no recomiendo usarla en tu maquina.

Editalo a tu gusto para evitar errores.

Asegúrese de que base-devel esté instalado antes de continuar.


# Problemas conocidos

-Hyprland está en versión beta en el momento de crear estos archivos de configuración y muchas variables y configuraciones pueden se incompatibles con nuevas versiones de Hyprland, recomiendo actualizar tu archivo de configuracion cada vez que salga una actualizacion de Hyprland.

-Los iconos de Eww pueden no aparecer, puedes resolverlo de la siguiente manera:

```bash
nvim ~/.config/eww/scss/variables.scss
```
PARA EL MENÚ DE ENERGÍA

```bash
nvim ~/.config/eww/scss/powermenu.scss
```

Tanto en el archivo /home/user/..... cambiar usuario a su nombre de usuario arreglará el
asunto

# Referencias

  GitHub oficial de Hyprland: https://github.com/hyprwm/Hyprland
  
  Archivos de Configuración de ChrisTitus: https://github.com/ChrisTitusTech/hyprland-titus
