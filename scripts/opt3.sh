#cd Auditoria_$(date +%Y-%m-%d)
#hcxpcapngtool -o handshake.22000 Auditoria-01.cap

until [ "$opthash" = "4" ]
do

echo -e "\e[1;31m$(cat log/log3)\e[0m"
echo ""

echo -e "\033[31m[!] Antes de hacer un ataque de fuerza bruta, asegurate de haber capturado el handshake\033[0m"
echo ""
echo -e "\033[31m[-] Menu de opciones: \033[0m"
echo ""
echo "[0] Seleccionar el juego de caracteres"
echo "[1] Seleccionar el tipo de dispositivo"
echo "[2] Seleccionar el perfil de carga"
echo "[3] Iniciar el ataque de fuerza bruta"
echo "[4] Salir"
echo ""
echo -e "\033[36m[*] Menu de estado:\033[0m"
echo ""
echo "[-] Juego de caracteres: ${char}"
echo "[-] ID de dispositivo:   ${dispID}"
echo "[-] Perfil de carga:     ${workload}"
echo ""
read -p $'\e[33m[-] Elige una opcion: \e[0m ' opthash
case $opthash in

	0)
		echo ""
		echo -e "\033[31m[-] Juego de caracteres: \033[0m"
		echo ""
		echo "[l] abcdefghijklmnopqrstuvwxyz [a-z]"
		echo "[u] ABCDEFGHIJKLMNOPQRSTUVWXYZ [A-Z]"
		echo "[d] 0123456789                 [0-9]"
		echo "[h] 0123456789abcdef           [0-9a-f]"
		echo "[H] 0123456789ABCDEF           [0-9A-F]"
		#echo "[s]  !#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
		echo ""
		read -p $'\e[33m[-] Escoja el juego de caracteres que desea utilizar: \e[0m ' char
		clear
		echo -e "\033[32m[!] Juego de caracteres seleccionado\033[0m"
		echo ""
	;;

	1)
		echo ""
		echo -e "\033[31m[-] Tipos de dispositivos: \033[0m"
                echo ""
                echo "[1] CPU"
                echo "[2] GPU"
                echo "[3] FPGA, DSP, Co-Processor"
		echo ""
		read -p $'\e[33m[-] Escoja el dispositivo a utilizar: \e[0m ' disp
		echo ""
		case $disp in
			1)
	                read -p $'\e[33m[-] A continuacion se mostraran los CPU disponibles, presione ENTER para continuar: \e[0m ' ENTER
        	        echo ""
                	hashcat -I
               		echo ""
               		read -p $'\e[33m[-] Escriba el numero que corresponde al ID del CPU que desea utilizar: \e[0m ' dispID
                	clear
                	echo -e "\033[32m[!] CPU seleccionado\033[0m"
                	echo ""
			;;

                        2)
                        read -p $'\e[33m[-] A continuacion se mostraran los GPU disponibles, presione ENTER para continuar: \e[0m ' ENTER
                        echo ""
                        hashcat -I
                        echo ""
                        read -p $'\e[33m[-] Escriba el numero que corresponde al ID del GPU que desea utilizar: \e[0m ' dispID
                        clear
                        echo -e "\033[32m[!] GPU seleccionado\033[0m"
                        echo ""
                        ;;

                        3)
                        read -p $'\e[33m[-] A continuacion se mostraran los FPGA disponibles, presione ENTER para continuar: \e[0m ' ENTER
                        echo ""
                        hashcat -I
                        echo ""
                        read -p $'\e[33m[-] Escriba el numero que corresponde al ID del FPGA que desea utilizar: \e[0m ' dispID
                        clear
                        echo -e "\033[32m[!] FPGA seleccionado\033[0m"
                        echo ""
                        ;;
		esac
	;;

        2)
                echo ""
                echo -e "\033[31m[-] Perfiles de carga: \033[0m"
                echo ""
                echo "[1] Low      (2 ms)"
                echo "[2] Default  (12 ms)"
                echo "[3] High     (96 ms)"
                echo "[4] Insane   (480 ms)"
                echo ""
                read -p $'\e[33m[-] Escoja el perfil de carga que desea utilizar: \e[0m ' workload
                clear
                echo -e "\033[32m[!] Perfil de carga seleccionado\033[0m"
                echo ""
        ;;

	3)
		echo ""
		echo -e "\033[31m[!] Iniciando ataque de fuerza bruta.\033[0m"
		echo ""
		cd Auditoria_$(date +%Y-%m-%d)
		hcxpcapngtool -o handshake.hc22000 Auditoria-01.cap
		echo ""
		hashcat -m 22000 handshake.hc22000 -a 3 ?$char?$char?$char?$char?$char?$char?$char?$char -d $dispID -D $disp -w $workload
		echo""
		echo -e "\033[32m[-] Ataque completado. \033[0m"
		echo ""
		read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m ' ENTER
		cd ..
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