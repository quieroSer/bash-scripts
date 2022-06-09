#!/bin/bash
#chequea si se paso 1 o 2 como argumento
if [ $# -eq 0 ]
then
	echo "Usage: $0 <argument>"
else
	if [ $# -gt 1 ]
	then
		echo "Usage: $0 <argument>"
	fi
fi

if [ $1 -eq 1 ]
then
	ENV_VAR="YES"
	export ENV_VAR
else
	if [ $1 -eq 2 ]
	then
		ENV_VAR="NO"
		export ENV_VAR
	else
		echo "Usage: $0 <1 or 2 are the only 2 valid arguments>"
	fi
fi

echo $ENV_VAR
echo "exiting"

