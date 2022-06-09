#!/bin/bash
echo "hello user $USERNAME"
echo "please choose a directoory name:"
read dirname
pwd
ORIG_DIR=$((pwd))
DNAME=$dirname
mkdir $DNAME
cd $DNAME
echo $CURRENT
echo $DNAME
for n in 1 2 3 4
do
	touch file$n
done
ls file?
for names in file?
do
	echo this file is named $names > $names
done

cat file?

cd ..
rm -rf $DNAME
echo "goodbye madafaca!"



