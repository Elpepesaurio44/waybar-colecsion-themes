#!/bin/bash

# Colores para la terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directorios
CONFIG_DIR="$HOME/.config/waybar"
BACKUP_DIR="$HOME/.config/waybar_backup_$(date +%Y%m%d_%H%M%S)"

# Función para instalar dependencias (Arch Linux / Hyprland)
install_deps() {
    echo -e "${BLUE}🔎 Verificando dependencias...${NC}"
    # Lista de paquetes necesarios
    PACKAGES=("waybar" "ttf-jetbrains-mono-nerd" "otf-font-awesome")
    
    for pkg in "${PACKAGES[@]}"; do
        if pacman -Qs $pkg > /dev/null; then
            echo -e "${GREEN}✔ $pkg ya está instalado.${NC}"
        else
            echo -e "${YELLOW}Installing $pkg...${NC}"
            sudo pacman -S --noconfirm $pkg
        fi
    done
}

# Función para previsualizar
preview_theme() {
    local theme=$1
    echo -e "${BLUE}👁️  Previsualizando: $theme${NC}"
    echo -e "${YELLOW}Cierra la ventana de Waybar o presiona Ctrl+C para volver al menú.${NC}"
    
    # Ejecuta waybar apuntando directamente a la carpeta del tema
    waybar -c "./$theme/waybar/config" -s "./$theme/waybar/style.css"
}

# Función para instalar
install_theme() {
    local theme=$1
    echo -e "${YELLOW}⚠️  Instalando $theme...${NC}"
    
    # Crear backup si existe config previa
    if [ -d "$CONFIG_DIR" ]; then
        echo -e "${BLUE}📦 Creando backup de tu config actual en $BACKUP_DIR${NC}"
        mv "$CONFIG_DIR" "$BACKUP_DIR"
    fi
    
    # Instalar nuevo tema
    mkdir -p "$CONFIG_DIR"
    cp -r "./$theme/waybar/"* "$CONFIG_DIR/"
    
    echo -e "${GREEN}✅ Tema instalado correctamente.${NC}"
    pkill waybar
    waybar &
}

# Menú principal
echo -e "${BLUE}--- Waybar Colecsion Selector ---${NC}"
themes=(*/)
select fav in "${themes[@]%/}" "Salir"; do
    if [[ $fav == "Salir" ]]; then
        break
    elif [[ -n $fav ]]; then
        echo -e "\nHas seleccionado: ${GREEN}$fav${NC}"
        echo "1) Previsualizar (sin instalar)"
        echo "2) Instalar y borrar anterior (hace backup)"
        echo "3) Instalar fuentes (JetBrainsMono)"
        echo "4) Volver"
        read -p "Opción: " opt
        
        case $opt in
            1) preview_theme "$fav" ;;
            2) install_theme "$fav" ;;
            3) install_deps ;;
            4) continue ;;
            *) echo "Opción inválida" ;;
        esac
    fi
done
