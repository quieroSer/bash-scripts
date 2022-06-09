#!/bin/bash
#prompts the user to give the right argument number/type
if [ $# -ne 1 ];then
	echo "please provide the right number of arguments";
	echo "Usage: $0 <arg> , arg should be a number between one and twelve";
	exit 1
fi
month=$1
case $month in
	1 | "uno" ) echo "enero";;
	2 | "dos" ) echo "febrero";;
	3 | "tres" ) echo "marzo";;
	4 | "cuatro" ) echo "abril";;
	5 | "cinco" ) echo "mayo";;
	6 | "seis" ) echo "junio";;
	7 | "siete" ) echo "julio";;
	8 | "ocho" ) echo "agosto";;
	9 | "nueve" ) echo "septiembre";;
	10 | "diez" ) echo "octubre";;
	11 | "once" ) echo "noviembre";;
	12 | "doce" ) echo "diciembre";;
	*) 
		echo "numero de mes no existe"
		echo "pro favor pasa un numero del 1 al 12"
		exit 2
		;;
esac
exit 0


