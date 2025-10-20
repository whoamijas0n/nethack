# empieza el bucle para seleccionar la distribucion

until [ "$opcion" = "2" ]
do

echo -e "\e[1;31m$(cat reqlog)\e[0m"
echo ""

# menu de opciones para seleccionar la distribucion

echo ""
echo -e "\033[33m[-] Distribuciones disponibles:\033[0m"
echo ""
echo "[0] Debian / Ubuntu / Kali Linux"
echo "[1] Arch Linux / BlackArch"
echo "[2] Salir"

echo ""

read -p $'\e[31m[-] Elige una opcion: \e[0m ' opcion

# empieza el menu de casos segun la opcion que se haya tomado

case $opcion in


        "0")	
                clear
		echo -e "\033[33m[!] Iniciando Instalacion.\033[0m"
                echo ""
		sudo apt update
		sudo apt install -y aircrack-ng kitty 
		echo ""
		read -p $'\e[32m[-] Instalacion completa, presione ENTER para continuar:\e[0m ' enter
		clear
                ;;

        "1")
                clear
		echo -e "\033[33m[!] Iniciando Instalacion.\033[0m"
		echo ""
		sudo pacman -Syu --noconfirm
		sudo pacman -S --needed aircrack-ng kitty
		echo ""
		read -p $'\e[32m[-] Instalacion completa, presione ENTER para continuar:\e[0m ' enter
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

