#!/bin/bash
#define the funcitons: add, subtract, multiply, divide
#each function will use three methods. the last one is deprecated
fadd () {
	x1=$(($1 + $2))
	let x2=($1 + $2)
       	x3=`expr $1 + $2`	
}

fsubtract () {
	x1=$(($1 - $2))
	let x2=($1 + $2)
	x3=`expr $1 + $2`
}

fmultiply () {
	x1=$(($1 * $2))
	let x2=($1 * $2)
	x3=`expr $1 \* $2`
}

fdivide () {
	x1=$(($1 / $2))
	let x2=($1 / $2)
	x3=`expr $1 / $2`
}

#end of functions

#check if the correct number of arguments are given
if [ $# -ne 3 ]
then
	echo "please provide the correct number of arguments"
	echo "Usage: $0 <operator: a, s, m, d> <num 1> <num 2>"
	exit 0
fi
#check if a correct operator is given
if [ $1 == a ]; then
	fadd $2 $3
elif [ $1 == s ]; then
	fsubtract $2 $3
elif [ $1 == m ]; then
	fmultiply $2 $3
elif [ $1 == d ]; then
	fdivide $2 $3
else
	echo "please provide the a correct operator"
	echo "a for add"
	echo "s for substract"
	echo "m for multiply"
	echo "d for divide"
	exit 0
fi

echo $2 $1 $3
echo 'Method 1, $((...)),' Answer is $x1
echo 'Method 2, let,     ' Answer is $x2
echo 'Method 3, expr,    ' Answer is $x3
echo "peace out"

exit 0



