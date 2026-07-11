# i3-nord-dotfiles

Configuración limpia de **i3wm** con tema **Nord** para **Debian estable (Trixie / 13)**.
Hecha a medida, sin dependencias de Arch/AUR: todo se instala desde repos oficiales con `apt`.

![theme](https://img.shields.io/badge/theme-Nord-88C0D0) ![wm](https://img.shields.io/badge/wm-i3-81A1C1) ![distro](https://img.shields.io/badge/distro-Debian%20Trixie-5E81AC)

## Componentes

| Función            | Programa                     |
|--------------------|------------------------------|
| Window manager     | i3                           |
| Terminal           | kitty                        |
| Gestor de archivos | thunar                       |
| Visor de imágenes  | feh / nsxiv                  |
| Lanzador           | rofi                         |
| Barra              | polybar                      |
| Compositor         | picom                        |
| Notificaciones     | dunst                        |
| Wallpaper          | feh                          |
| Bloqueo            | i3lock + xautolock           |
| Display manager    | LightDM                      |
| Fuente             | JetBrainsMono Nerd Font      |

## Instalación

```bash
git clone <URL-DE-TU-REPO> ~/i3-nord-dotfiles
cd ~/i3-nord-dotfiles
./install.sh
```

El script:
1. Instala los paquetes de `packages.txt` con `apt`.
2. Descarga e instala **JetBrainsMono Nerd Font** en `~/.local/share/fonts`.
3. Copia las configs a `~/.config/` (haciendo backup de las existentes).
4. Copia el wallpaper a `~/Pictures/wallpapers/`.
5. Habilita LightDM.

Después: **reinicia** y elige la sesión **i3** en LightDM.

## Instalación manual (alternativa)

```bash
sudo apt update
sudo apt install $(grep -vE '^\s*#|^\s*$' packages.txt)
cp -r config/* ~/.config/
```
Instala la Nerd Font a mano en `~/.local/share/fonts` y ejecuta `fc-cache -f`.

## Wallpaper

Coloca tu fondo en `wallpapers/nord.png` (o edita la línea `feh --bg-fill` en
`config/i3/config`). Buenos wallpapers Nord: <https://github.com/dxnst/nord-wallpapers>

## Temas GTK / iconos

Usa `lxappearance` para aplicar un tema GTK Nord y iconos:
- Tema GTK: **Nordic** (<https://github.com/EliverLara/Nordic>)
- Iconos: **Papirus** (ya incluido en `packages.txt`)

## Atajos de teclado principales

| Atajo                     | Acción                        |
|---------------------------|-------------------------------|
| `Super + Enter`           | Terminal (kitty)              |
| `Super + D`               | Lanzador (rofi)               |
| `Super + E`               | Gestor de archivos (thunar)   |
| `Super + B`               | Navegador                     |
| `Super + Q`               | Cerrar ventana                |
| `Super + F`               | Pantalla completa             |
| `Super + Space`           | Flotante on/off               |
| `Super + 1..0`            | Cambiar de workspace          |
| `Super + Shift + 1..0`    | Mover ventana a workspace     |
| `Super + H/J/K/L`         | Mover foco                    |
| `Super + Shift + H/J/K/L` | Mover ventana                 |
| `Super + R`               | Modo redimensionar            |
| `Super + Shift + X`       | Bloquear pantalla             |
| `Print` / `Super + Print` | Captura completa / con área   |
| `Super + Shift + R`       | Reiniciar i3                  |
| `Super + Shift + E`       | Salir de i3                   |

## Estructura

```
i3-nord-dotfiles/
├── config/
│   ├── i3/config
│   ├── polybar/{config.ini,launch.sh}
│   ├── picom/picom.conf
│   ├── rofi/{config.rasi,nord.rasi}
│   ├── dunst/dunstrc
│   └── kitty/kitty.conf
├── wallpapers/
├── packages.txt
├── install.sh
└── README.md
```

## Paleta Nord

`#2E3440` `#3B4252` `#434C5E` `#4C566A` · `#D8DEE9` `#ECEFF4` · `#8FBCBB` `#88C0D0` `#81A1C1` `#5E81AC` · `#BF616A`

## Licencia

MIT
