#!/bin/bash
#este script es para descomprimr recursivamente un archivo que ha sido comprimido varias veces, para el desafio overthewire bandit nivel 12

name_decompressed=$(7z l datos.gz | grep "Name" -A 2 | tail -n 1 | awk 'NF{print $NF}')
# >
7z x datos.gz > /dev/null 2>&1

while true; do
	7z l $name_decompressed > /dev/null 2>&1

	if [ "$(echo $?)" == "0" ]; then
		decompressed_next=$(7z l $name_decompressed | grep "Name" -A 2 | tail -n 1 | awk 'NF{print $NF}')
		7z x $name_decompressed > /dev/null 2>&1 && name_decompressed=$decompressed_next
	else
		cat $name_decompressed | awk 'NF{print $NF}'; rm data* 2>/dev/null 
		exit 1
	fi
done


