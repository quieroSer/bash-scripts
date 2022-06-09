#!/bin/bash
#read two strings as arguments
echo "please provide 2 strings to compare:"
echo ""
read str1 str2
len1=${#str1}
len2=${#str2}

if [ $len1 -eq 0 ] && [ $len2 -ne 0]; then
	echo "the lenght of the first string is zero and the second is not zero"
fi

if [ $len1 -gt $len2 ]; then
	echo "first string is longer than the second one"
elif [ $len2 -gt $len1 ]; then
	echo "second string is longer than the first one"
else
	echo "both string are the same size"
fi

if [ "$str1" == "$str2" ]; then
	echo "both strings are the same!"
else
	echo "both strings are different!"
fi

echo "bye madafaca"


