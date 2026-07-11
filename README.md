# i3-cyberpunk-dotfiles

Configuración de **i3wm** con tema **Cyberpunk Neon** para **Debian 13 (Trixie)** en Hyper-V.
Optimizado para bajo consumo de RAM (~300 MB en idle) con máximo impacto visual.

![theme](https://img.shields.io/badge/theme-Cyberpunk-00f0ff) ![wm](https://img.shields.io/badge/wm-i3-ff007f) ![distro](https://img.shields.io/badge/distro-Debian%20Trixie-7c3aed)

## Stack visual

| Función            | Programa       | Rol estético                          |
|--------------------|----------------|---------------------------------------|
| Window manager     | i3             | Bordes neón, gaps amplios             |
| Terminal           | kitty          | Transparencia 92%, blur al fondo      |
| Compositor         | picom          | dual_kawase blur, sombras cian, esquinas redondeadas 12px |
| Barra              | polybar        | Workspaces + iconos Nerd Font         |
| Lanzador           | rofi           | Tema cyberpunk con border cian        |
| Notificaciones     | dunst          | Esquinas redondeadas, frames neón     |
| Visualizador audio | cava           | Barras gradiente pink→purple→cyan     |
| Monitor sistema    | btop           | Tema cyberpunk con todos los recursos |
| Info sistema       | neofetch       | ASCII cyberpunk al abrir terminal     |
| Montaje USB        | udiskie        | Auto-montaje con icono en bandeja     |
| Wallpaper          | feh            | Cyberpunk art fijo                    |
| Bloqueo            | i3lock         | Pantalla negra #0a0e14               |
| Display manager    | LightDM        | Greeter cyberpunk                     |
| Fuente             | JetBrainsMono Nerd Font | Iconos consistentes en todo el sistema |

## Paleta Cyberpunk Neon

```
Fondo:     #0a0e14  #111820  #1a2430
Texto:     #c0caf5  #565f89  #e0e8ff
Neón cian: #00f0ff  (primario)
Neón pink: #ff007f  (secundario)
Neón púrp: #7c3aed  (terciario)
Matrix gn: #00ff41  (éxito)
Neón red:  #ff0040  (error/urgente)
Gold:      #ffd700  (warning)
```

## Instalación

```bash
git clone <URL-DE-TU-REPO> ~/i3-cyberpunk-dotfiles
cd ~/i3-cyberpunk-dotfiles
./install.sh
```

El script:
1. Instala paquetes con `apt` (xorg, i3, picom, polybar, kitty, rofi, dunst...)
2. Descarga e instala **JetBrainsMono Nerd Font** en `~/.local/share/fonts`
3. Instala iconos Papirus-Dark + tema GTK Adwaita-dark
4. Copia configs a `~/.config/` (backup automático de las existentes)
5. Copia wallpaper a `~/Pictures/wallpapers/`
6. Aplica tema Cyberpunk al greeter de LightDM
7. Habilita LightDM

Después: **reinicia** y elige sesión **i3** en LightDM.

### Opciones de prueba (sin tocar el sistema)

```bash
HOME=/tmp/testhome SKIP_APT=1 SKIP_FONT=1 SKIP_DM=1 ./install.sh
```

| Variable      | Efecto                    |
|---------------|---------------------------|
| `SKIP_APT=1`  | No instala paquetes       |
| `SKIP_FONT=1` | No descarga Nerd Font     |
| `SKIP_DM=1`   | No toca LightDM           |

## Desinstalación

```bash
./uninstall.sh
```
Elimina configs y restaura backup más reciente. Opciones:

| Variable           | Efecto                                        |
|--------------------|-----------------------------------------------|
| `PURGE_PACKAGES=1` | También desinstala paquetes de packages.txt   |
| `REMOVE_FONT=1`    | Elimina la Nerd Font                          |
| `ASSUME_YES=1`     | No pide confirmación                          |

## Atajos de teclado

| Atajo                     | Acción                        |
|---------------------------|-------------------------------|
| `Super + Enter`           | Terminal (kitty)              |
| `Super + D`               | Lanzador (rofi)               |
| `Super + E`               | Gestor de archivos (thunar)   |
| `Super + B`               | Navegador                     |
| `Super + Q`               | Cerrar ventana                |
| `Super + Ctrl + C`        | Visualizador audio (cava)     |
| `Super + Ctrl + B`        | Monitor sistema (btop)        |
| `Super + F`               | Pantalla completa             |
| `Super + Space`           | Flotante on/off               |
| `Super + 1..0`            | Cambiar workspace             |
| `Super + Shift + 1..0`    | Mover ventana a workspace     |
| `Super + H/J/K/L`         | Mover foco                    |
| `Super + Shift + H/J/K/L` | Mover ventana                 |
| `Super + R`               | Modo redimensionar            |
| `Super + Shift + X`       | Bloquear pantalla             |
| `Print` / `Super + Print` | Captura completa / con área   |
| `Super + Shift + R`       | Reiniciar i3                  |
| `Super + Shift + E`       | Salir de i3                   |

## Estructura del proyecto

```
i3-cyberpunk-dotfiles/
├── config/
│   ├── i3/config              # Window manager
│   ├── polybar/
│   │   ├── config.ini         # Barra de estado
│   │   └── launch.sh
│   ├── picom/picom.conf       # Compositor (blur, sombras, esquinas)
│   ├── rofi/
│   │   ├── config.rasi        # Lanzador
│   │   └── cyberpunk.rasi     # Tema del lanzador
│   ├── dunst/dunstrc          # Notificaciones
│   ├── kitty/kitty.conf       # Terminal
│   ├── cava/config            # Visualizador de audio
│   ├── btop/
│   │   ├── btop.conf          # Monitor del sistema
│   │   └── themes/cyberpunk.theme  # Tema personalizado
│   └── neofetch/
│       ├── config.conf        # Info de sistema
│       └── ascii.txt          # Logo ASCII cyberpunk
├── system/
│   └── lightdm-gtk-greeter.conf
├── wallpapers/                # Coloca tu cyberpunk.png aquí
├── packages.txt
├── install.sh
├── uninstall.sh
├── LICENSE
└── README.md
```

## Renderizado visual

El compositor **picom** genera el "glassmorphism" cyberpunk:

- **Blur**: dual_kawase con strength 7 — el fondo detrás de las ventanas se ve borroso como vidrio holográfico
- **Esquinas**: 12px de radio en todas las ventanas (excepto polybar y docks)
- **Sombras**: offset -14px con tinte cian (#00f0ff) para simular glow neón
- **Transparencia**: ventanas inactivas al 88%, activas al 96%

El efecto combinado: paneles flotantes de vidrio oscuro con bordes de luz cian.

## Capas cyberpunk adicionales

| Herramienta | Atajo              | Visual                          |
|-------------|--------------------|---------------------------------|
| **cava**    | `Super+Ctrl+C`     | Barras de audio con gradiente pink→purple→cyan, fondo #0a0e14 |
| **btop**    | `Super+Ctrl+B`     | Monitor CPU/RAM/Net con tema personalizado (mismos colores del sistema) |
| **neofetch**| (auto al abrir terminal) | Logo ASCII cyberpunk + info del sistema en neón |
| **udiskie** | (automático)       | Icono en bandeja del sistema para montar USBs |

## Workflow

- **Resolución**: si Hyper-V arranca en 1024x768, descomenta la línea `xrandr` en `config/i3/config:54`
- **USBs**: `udiskie` monta automáticamente en segundo plano con icono en bandeja
- **Capturas**: `Print` = pantalla completa, `Super+Print` = selección de área (flameshot)

## Tipografía

**JetBrainsMono Nerd Font** — versión 3.0+. Incluye ~4000 iconos (material, font-awesome, powerline, devicons) para polybar, rofi y kitty sin fuentes adicionales.

## Licencia

MIT
