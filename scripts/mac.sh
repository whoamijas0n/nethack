echo ""
echo -e "\033[31m[!] Antes, tienes que ingresar el nombre de tu interfaz; \033[0m"
echo ""
echo -e "\033[31m[!] Estas son las interfaces disponibles; \033[0m"
echo ""
iwconfig 2>/dev/null | grep -E "^[a-z]" | cut -d' ' -f1
echo ""
read -p $'\e[33m[-] Escribe el nombre de tu interfaz \e[0m ' interfasname


clear

until [ "$optmac" = "5" ]
do

echo -e "\e[1;31m$(cat log/log-mac)\e[0m"
echo ""
echo -e "\033[33m[*] ¡Cambia tu direccion MAC para una auditoria mas segura! \033[0m"
echo ""
echo -e "\033[31m[-] Menu de opciones: \033[0m"
echo ""
echo "[0] Resetear a la direccion MAC original"
echo "[1] Asignar una MAC aleatoria del mismo fabricante"
echo "[2] Cambiar a una MAC random"
echo "[3] Ver la lista de fabricantes soportados por macchanger"
echo "[4] Utilizar una MAC personalizada"
echo "[5] Salir"
echo ""
echo -e "\033[36m[*] Informacion de la MAC actual:\033[0m"
echo ""
sudo macchanger -s ${interfasname}
echo ""

read -p $'\e[33m[-] Elige una opcion: \e[0m ' optmac

ifconfig $interfasname down

case $optmac in


        0)
                echo ""
                echo -e "\033[31m[-] Reseteando a la MAC original \033[0m"
                echo ""
                sudo macchanger -p  ${interfasname}
		ifconfig ${interfasname} up  

		echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                clear
                echo -e "\033[32m[!] Volviendo al menu principal\033[0m"
                echo ""
        ;;

	1)
                echo ""
                echo -e "\033[31m[-] Asignando una MAC aleatoria del mismo fabricante \033[0m"
                echo ""
                sudo macchanger -a ${interfasname}
		ifconfig ${interfasname} up
		echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                clear
                echo -e "\033[32m[!] Cambios aplicados correctamente, volviendo al menu principal\033[0m"
                echo ""
        ;;

        2)
                echo ""
                echo -e "\033[31m[-] Cambiando a una MAC random \033[0m"
                echo ""
                sudo macchanger -r  ${interfasname}
		ifconfig ${interfasname} up
		echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                clear
                echo -e "\033[32m[!] Cambios aplicados correctamente, volviendo al menu principal\033[0m"
                echo ""
        ;;

        3)
                echo ""
                echo -e "\033[31m[-] Lista de fabricantes soportados por macchanger\033[0m"
                echo ""
                sudo macchanger -l
		echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                clear
                echo -e "\033[32m[!] Volviendo al menu principal\033[0m"
                echo ""
        ;;


        4)
                echo ""
                read -p $'\e[33m[-] Ingresa tu MAC personalizada: \e[0m ' macpe
                echo ""
                sudo macchanger -m $macpe $interfasname
		ifconfig ${interfasname} up
		echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                clear
                echo -e "\033[32m[!] Cambios aplicados correctamente, volviendo al menu principal\033[0m"
                echo ""
        ;;

        5)
                clear
                echo -e "\033[32m[!] Volviendo al menu principal\033[0m"
                echo ""
        ;;


        *)
                clear
                echo -e "\033[31m[!] Opcion invalida, repita denuevo.\033[0m"
                echo ""
        ;;




esac


done
