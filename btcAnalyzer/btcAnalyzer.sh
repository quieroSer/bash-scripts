#!/bin/bash

# Autor: javier ortiz (aka quieroSer)

#Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#esto se activa en caso de presionar CTRL + C
trap ctrl_c INT

function ctrl_c() {
	echo -e "\n${redColour}[!] Saliendo ...\n${endColour}"
	
	rm ut.t* money* total_entrada_salida.tmp entradas.tmp salidas.tmp 2>/dev/null	
	tput cnorm; exit 1
}

#variables globales
unconfirmed_transactions="https://www.blockchain.com/btc/unconfirmed-transactions"
inspect_transaction_url="https://www.blockchain.com/es/btc/tx/"
inspect_address_url="https://www.blockchain.com/es/btc/address/"

##############################################################################################

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

#############################################################################################

#funcion de panel de ayuda, para orientar al usuario con respecto al uso de la herramienta
function helpPanel() {
	echo -e "\n${redColour}[!] Uso: ./btcAnalyzer${endColour}"
	for i in $(seq 1 80); do echo -ne "${redColour}-";done; echo -ne "${endColour}"
	echo -e "\n\n\t${grayColour}[-e]${endColour}${yellowColour} Modo Exploración${endColour}"
	echo -e "\t\t${purpleColour}unconfirmed_transactions${endColour}${yellowColour}:\t Listar transacciones no confirmadas${endColour}"
	echo -e "\t\t${purpleColour}inspect${endColour}${yellowColour}:\t\t\t Inspeccionar un hash de transaccion${endColour}"
	echo -e "\t\t${purpleColour}address${endColour}${yellowColour}:\t\t\t Inspeccionar una transaccion de direccion${endColour}"
	echo -e "\n\t${grayColour}[-n]${endColour}${yellowColour} Limitar el numero de resultados ${endColour}${blueColour} (ejemplo: -n 10) ${endcolour}" 
	echo -e "\n\t${grayColour}[-i]${endColour}${yellowColour} Proporcionar el identificador de transacción${endColour}${blueColour} (ejemplo -i d9af1d9010fc8200bc0231bcbdd452c7962e0e3c01dacbc333b6a4694805051c) ${endColour}"
	echo -e "\n\t${grayColour}[-a]${endColour}${yellowColour} Proporcionar una direccion de bitcoin${endColour}${blueColour} (ejemplo -a 3PvEv6pP9roUEvPe5pWgQ5271dc9kH9QMB) ${endColour}"
	echo -e "\n\t${grayColour}[-h]${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}\n" 
	###esta linea hace que el cursor vuelva a la normalidad, y sale del programe indicando ejecucion fallida
	tput cnorm; exit 1
}

#funcion para generar la tabla de transacciones no confirmadas, segun el nodo asociado a blockhain.com
function unconfirmedTransactions(){
	
	number_output=$1
	echo '' > ut.tmp
	while [ "$( cat ut.tmp | wc -l)" == "1" ]; do
		curl -s "$unconfirmed_transactions" | html2text > ut.tmp 
	done
	hashes=$(cat ut.tmp | grep "Hash" -A 1 | grep -v -E "Hash|\--|Time" | head -n $number_output)	
	
	##El cirterio que definio para especificar la separacion de los nombres de las columnas es el _ #####
	echo "Hash_Cantidad_Bitcoin_Tiempo" > ut.table
	
	for hash in $hashes; do
		valorUSD="$(cat ut.tmp | grep "$hash" -A 6 | tail -n 1)"
		valorBTC="$(cat ut.tmp | grep "$hash" -A 4 | tail -n 1)"
		valorTiempo="$(cat ut.tmp | grep "$hash" -A 2 | tail -n 1)"
		echo "$hash,_,$valorUSD,_,$valorBTC,_,$valorTiempo" | tr -d , >> ut.table
	done

	cat ut.table | tr '_' ' ' | awk '{print $2}' | grep -v "Cantidad" | tr -d '$' | sed 's/\..*//g' | tr -d ',' > money
	
	money=0; cat money | while read money_in_line; do
		let money+=$money_in_line
		echo $money > money.tmp
	done;

	echo -n "Cantidad total_" > amount.table
	echo "\$$(printf "%'.d\n" $(cat money.tmp))" >> amount.table

	if [ -s ut.table ]; then
		echo -ne "${yellowColour}"
		printTable '_' "$(cat ut.table)"
		echo -ne "${endColour}"
		echo -ne "${greenColour}"
		printTable '_' "$(cat amount.table)"
		echo -ne "${endColour}"
		rm ut.* money* amount.table 2>/dev/null
		tput cnorm; exit 0
	else
		rm ut.* 2>/dev/null
	fi
	
	rm ut.t* 2>/dev/null
	tput cnorm
}

function inspectTransaction(){
	transaction_hash=$1
	echo "Endtrada Total_Salida Total" > total_entrada_salida.tmp
	while [ "$(cat total_entrada_salida.tmp | wc -l)" == "1"  ]; do
		curl -s "${inspect_transaction_url}${transaction_hash}" | html2text | grep -E "Entradas totales|Gastos totales" -A 1 | grep -v -E "Entradas totales|Gastos totales" | xargs | tr ' ' '_' | sed 's/_BTC/ BTC/g' >> total_entrada_salida.tmp
	done

	echo -ne "${grayColour}"
	printTable '_' "$(cat total_entrada_salida.tmp)"
	echo -ne "${endColour}"
	rm total_entrada_* 2>/dev/null

	echo "Direccion (entradas)_valor" > entradas.tmp
	while [ "$(cat entradas.tmp | wc -l)" == "1" ]; do
		curl -s "${inspect_transaction_url}${transaction_hash}" | html2text | grep "Entradas" -A 500 | grep "Gastos" -B 500 |\
	 	 grep "Direcci" -A 3 | grep -v -E "Direcci|Valor|\--" | awk 'NR%2{printf "%s ",$0;next;}1' | awk '{print $1 "_" $2 " " $3}' >> entradas.tmp
	done

	echo -ne "${greenColour}"
	printTable '_' "$(cat entradas.tmp)"
	echo -ne "${endColour}"
	rm entradas.tmp 2>/dev/null

	
	echo "Direccion (salidas)_valor" > salidas.tmp
	while [ "$(cat salidas.tmp | wc -l)" == "1" ]; do
		curl -s "${inspect_transaction_url}${transaction_hash}" | html2text | grep "Gastos" -A 500 | grep "Crear un Wallet" -B 500 |\
	 	 grep "Direcci" -A 3 | grep -v -E "Direcci|Valor|\--" | awk 'NR%2{printf "%s ",$0;next;}1' | awk '{print $1 "_" $2 " " $3}' >> salidas.tmp
	done

	echo -ne "${greenColour}"
	printTable '_' "$(cat salidas.tmp)"
	echo -ne "${endColour}"
	rm salidas.tmp 2>/dev/null	
	tput cnorm
}

function inspectAddress(){
	address=$1
	echo "Transacciones realizadas_Cantidad total recibida (BTC)_Cantidad total enviada (BTC)_Saldo total en la cuenta" > address.info
	curl -s "${inspect_address_url}${address}" | html2text | grep -E "Transacciones|Total recibido|Total enviado|Saldo final" -A 1 | head -n -2 | grep -v -E "Transacciones|Total recibido|Total enviado|Saldo final" | xargs | tr ' ' '_' | sed 's/_BTC/ BTC/g' >> address.info
	
	echo -ne "${grayColour}"
	printTable '_' "$(cat address.info)"
	echo -ne "${endColour}"
	rm address.info 2>/dev/null
	
	btc_value=$(curl -s https://cointelegraph.com/bitcoin-price | html2text | grep "Last Price" | head -n 1 | awk 'NF{print $ NF}' | tr -d ',$')
	
	
	curl -s "${inspect_address_url}${address}" | html2text | grep "Transacciones" -A 1 | head -n -2 | grep -v -E "Transacciones|\--" > otra.info
	curl -s "${inspect_address_url}${address}" | html2text | grep -E "Total recibido|Total enviado|Saldo final" -A 1 | grep -v -E "Total recibido|Total enviado|Saldo final|\--" > btc2dollars
	
	cat btc2dollars | while read value; do
		echo "\$$(printf "%'.d\n" $(echo "$(echo $value | awk '{print $1}')*$btc_value" | bc) 2>/dev/null)" >> otra.info
	done	
	
	line_null=$(cat otra.info | grep -n "^\$$" | awk '{print $1}' FS=":")

	if [ "$(echo $line_null | grep -oP '\w')" ]; then
		echo $line_null | tr ' ' '\n' | while read line; do
			sed "${line}s/\$/0.00/" -i otra.info
		done
	fi

	cat otra.info | xargs | tr ' ' '_' >> otra.info2
	rm otra.info 2>/dev/null && mv otra.info2 otra.info
	#### cuando en el comando sed se parte con 1i, quiere decir que en la primera linea, insertes los q va a continuacion
	sed '1iTransacciones realizadas_Cantidad total recibidas (USD)_Cantidad total enviada (USD)_ Saldo actual en la cuenta (USD)' -i otra.info

	echo -ne "${grayColour}"
	printTable '_' "$(cat otra.info)"
	echo -ne "${endColour}"

	rm otra.info* btc2dollars 2>/dev/null	

	tput cnorm
}



#funcionamiento general de la herramienta
parameter_counter=0; while getopts "e:n:i:a:h:" arg; do
	case $arg in
		e) exploration_mode=$OPTARG; let parameter_counter+=1;;
		n) number_output=$OPTARG; let parameter_counter+=1;;
		i) inspect_transaction=$OPTARG; let parameter_counter+=1;;
		a) inspect_address=$OPTARG; let parameter_counter+=1;;
		h) helpPanel;;
	esac
done

###Esta linea hace que desaparezca el cursor
tput civis

if [ $parameter_counter -eq 0 ]; then
	helpPanel
else
	if [ "$(echo $exploration_mode)" == "unconfirmed_transactions" ]; then
		if [ ! "$number_output" ]; then
			number_output=100
			unconfirmedTransactions $number_output
		else
		unconfirmedTransactions $number_output
		fi
	elif [ "$(echo $exploration_mode)" == "inspect" ]; then
		inspectTransaction $inspect_transaction
	elif [ "$(echo $exploration_mode)" == "address" ]; then
		inspectAddress $inspect_address
	fi
fi
