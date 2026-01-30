bssid=$(cat Auditoria_$(date +%Y-%m-%d)/bssid.txt)

until [ "$option1" = "3" ]
do

# se ejecuta el script para el logo y informacion de el programa

echo -e "\e[1;31m$(cat log/log2)\e[0m"

cd Auditoria_$(date +%Y-%m-%d)

# menu de opciones para seleccionar la accion que se desea llevar a cabo

echo ""
echo -e "\033[33m[-] Menu de opciones:\033[0m"
echo ""
echo "[1] Seleccionar un diccionario"
echo "[2] Iniciar auditoria"
echo "[3] Salir"
echo ""
echo -e "\033[36m[*] Menu de estado:\033[0m"
echo ""
echo "[-] BSSID objetivo: $bssid" 
echo "[-] Ruta de el diccionario a utilizar: $diccionario" 

echo ""
echo -e "\033[31m[!] Para hacer un ataque de diccionario primero tienes que haber capturado el handshake.\033[0m"

echo ""

read -p $'\e[31m[-] Elige una opcion: \e[0m ' option1

# empieza el menu de casos segun la opcion que se haya tomado

case $option1 in
	
	"1")
        echo ""
        read -p $'\e[33m[-] Escribe la ruta del diccionario a utilizar: \e[0m ' diccionario
        cd ..
        clear
	;;

	"2")
        clear
		sudo aircrack-ng -b $bssid -w $diccionario Auditoria-01.cap
        echo ""
        read -p $'\e[31m[-] Ataque finalizado, presione ENTER para volver al menu principal. \e[0m ' enter
        cd ..
        clear
        echo -e "\033[32m[!] Auditoria finalizada\033[0m"
		echo ""
	
    ;;

	"3")
		clear
		echo -e "\033[32m[!] Regresando a el menu principal\033[0m"
		echo ""
	;;
	
	*)
		clear
		echo -e "\033[31m[!] Opcion invalida, repita denuevo.\033[0m"
		cd ..
	;;


# Termina el menu de casos
esac

# termina el bucle de el menu principal
done







