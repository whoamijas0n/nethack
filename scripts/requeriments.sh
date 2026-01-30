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
            # Instalamos las herramientas base y de red necesarias para tus scripts
            sudo apt install -y aircrack-ng macchanger hashcat hcxtools kitty net-tools wireless-tools eaphammer
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