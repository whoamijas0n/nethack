#!/bin/bash

# Lista de dependencias detectadas en tus scripts
# Incluye: aircrack-ng, macchanger, hashcat, hcxtools, kitty, net-tools, wireless-tools y eaphammer
DEPS=("aircrack-ng" "macchanger" "hashcat" "hcxpcapngtool" "kitty" "ifconfig" "iwconfig" "eaphammer")

# Función para verificar el estado de las herramientas
check_status() {
    echo -e "\033[36m[*] Estado de las dependencias:\033[0m"
    echo ""
    for tool in "${DEPS[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "[\033[32mOK\033[0m] $tool"
        else
            echo -e "[\033[31mX\033[0m] $tool (Faltante)"
        fi
    done
    echo ""
}

# Empieza el bucle para seleccionar la distribucion
until [ "$opcion" = "2" ]
do
    # Se muestra el logo (si existe el archivo)
    if [ -f "log/log-requeriments" ]; then
        echo -e "\e[1;31m$(cat log/log-requeriments)\e[0m"
    fi
    
    echo ""
    # Se muestra el estado actual antes del menú
    check_status

    # Menu de opciones
    echo -e "\033[33m[-] Distribuciones disponibles:\033[0m"
    echo ""
    echo "[0] Debian / Ubuntu / Kali Linux"
    echo "[1] Arch Linux / BlackArch"
    echo "[2] Salir"
    echo ""

    read -p $'\e[31m[-] Elige una opcion: \e[0m ' opcion

    case $opcion in
        "0")    
            clear
            echo -e "\033[33m[!] Iniciando Instalacion en base Debian...\033[0m"
            echo ""
            sudo apt update
            
            # PASO 1: Instalamos herramientas base del repositorio (SIN eaphammer)
            # Agregamos git, python3-pip y librerias necesarias para compilar eaphammer
            echo -e "\033[36m[*] Instalando dependencias desde repositorios...\033[0m"
            sudo apt install -y aircrack-ng macchanger hashcat hcxtools kitty net-tools wireless-tools git python3-pip libssl-dev libffi-dev build-essential
            
            # PASO 2: Instalación Manual de Eaphammer
            echo ""
            echo -e "\033[36m[*] Iniciando instalación manual de Eaphammer...\033[0m"
            
            # Verificamos si ya existe el directorio para no clonar encima
            if [ -d "eaphammer" ]; then
                echo "[-] Carpeta eaphammer detectada. Actualizando repositorio..."
                cd eaphammer
                git pull
            else
                echo "[-] Clonando repositorio oficial..."
                git clone https://github.com/s0lst1c3/eaphammer.git
                cd eaphammer
            fi

            # Ejecutamos el script de instalación propio de la herramienta
            echo "[-] Ejecutando setup de eaphammer..."
            sudo ./kali-setup
            
            # Crear enlace simbólico para que el comando 'eaphammer' funcione globalmente
            # Esto es vital para que tu función check_status detecte 'OK'
            echo "[-] Creando enlace simbólico..."
            sudo ln -sf "$(pwd)/eaphammer" /usr/local/bin/eaphammer
            
            # Regresamos al directorio original
            cd ..
            
            echo ""
            read -p $'\e[32m[-] Proceso finalizado, presione ENTER para verificar:\e[0m ' enter
            clear
            ;;

        "1")
            clear
            echo -e "\033[33m[!] Iniciando Instalacion en base Arch...\033[0m"
            echo ""
            sudo pacman -Syu --noconfirm
            # En Arch/BlackArch los nombres suelen coincidir o estar agrupados
            # Nota: Si eaphammer no está en repos oficiales de Arch, necesitarías usar AUR (yay/paru)
            sudo pacman -S --needed --noconfirm aircrack-ng macchanger hashcat hcxtools kitty net-tools eaphammer
            echo ""
            read -p $'\e[32m[-] Proceso finalizado, presione ENTER para verificar:\e[0m ' enter
            clear
            ;;

        "2")
            clear
            echo -e "\033[32m[!] Volviendo al menu principal.\033[0m"
            echo ""
            ;;

        *)
            clear
            echo -e "\033[31m[!] Opcion invalida, repita denuevo.\033[0m"
            echo ""
            ;;
    esac
done