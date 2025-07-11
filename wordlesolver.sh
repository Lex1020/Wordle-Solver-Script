#!/bin/bash
user=$(whoami)
echo "Enter a Username:"
read uname
if [ -f /tmp/runcheck$uname ];  then
	echo "Welcome back $uname. Resuming from where you left off."
fi
echo "Welcome to the Wordle Solver."
echo "=========================================="
echo "Checking Prerequisites. One moment."
if [ -f /home/$user/wordlewords ]; then
	echo "Dictonary Found. Proceeding with program."
	echo "========================================="
	else 
		echo "Downloading file."
		wget -q --show-progress https://raw.githubusercontent.com/tabatkins/wordle-list/main/words
		mv words /home/$user/wordlewords
		echo "Dictonary downloaded. Proceefing with program."
		echo "=============================================="
fi
echo "Please enter the first range of letters. (Note: enter them as a-z, or if you are eliminating letters then enter them as a range like a-df-z)"
read letter1
echo "Please enter the range of your second letter."
read letter2
echo "Please enter the range of your third letter." 
read letter3
echo "Please enter the range of your fourth letter."
read letter4 
echo "Please enter the range of your fifth letter."
read letter5
echo "Are there any letters you wish to eliminate? (Y/N)"
read answer1
grep -Ei "^([$letter1]{1}[$letter2]{1}[$letter3]{1}[$letter4]{1}[$letter5]{1})$" /home/$user/wordlewords > /tmp/wordleguesses$uname.txt
cp /tmp/wordleguesses$uname.txt /tmp/wordleguesses2$uname.txt
if [ $answer1 == Y ]; then
	echo "Enter ther letters to eliminate."
	read Eletters
	echo $Eletters >> /tmp/letters$uname.txt
	echo "Eliminated Letters"
	(tr -d "\n" </tmp/letters$uname.txt ;echo) | tee /tmp/letters$uname.txt
	EL=$(cat /tmp/letters$uname.txt)
	grep -Evi "([$EL])" /tmp/wordleguesses$uname.txt > /tmp/wordleguesses2$uname.txt
	mv /tmp/wordleguesses2$uname.txt /tmp/wordleguesses$uname.txt
fi
echo " "
echo "Are there any letters you know exist, but not the place? (Y/N)"
read answer
if [ $answer == Y ]; then
	cp /tmp/wordleguesses$uname.txt /tmp/words$uname
	echo "How many letters? (Enter 1-5)"
	read i
	while [ $i -gt 0 ];
		do 
			echo "What is letter $i"
			read letter
			grep -Ei "([$letter])" /tmp/words$uname >> /tmp/wordleguesses2$uname.txt
                        mv /tmp/wordleguesses2$uname.txt /tmp/words$uname
			cp /tmp/words$uname /tmp/wordleguesses$uname.txt
			((i--))
		done
fi
echo "Your Wordle suggestions are:"
echo "============================================================="
cat /tmp/wordleguesses$uname.txt
echo "============================================================="
rm /tmp/wordleguesses*$uname.txt /tmp/words$uname > /dev/null 2>&1
echo "Did you solve the word? (Y/N)"
read solve
if [ $solve == Y ]; then 
	echo "Cleaning up."
	rm /tmp/letters$uname.txt /tmp/runcheck$uname.txt > /dev/null 2>&1
	elif [ $solve == N ]; then 
	clear
	echo "Running script again."
	touch  /tmp/runcheck$uname.txt
	./wordlesolver.sh
fi
