#!/bin/bash
user=$(whoami)
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
#echo "Your first quess is $letter1"
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
grep -Ei "^([$letter1]{1}[$letter2]{1}[$letter3]{1}[$letter4]{1}[$letter5]{1})$" /home/$user/wordlewords > /tmp/wordleguesses.txt
cp /tmp/wordleguesses.txt /tmp/wordleguesses2.txt
if [ $answer1 == Y ]; then
	echo "Enter ther letters to eliminate."
	read Eletters
	echo $Eletters >> /tmp/letters.txt
	echo "Eliminated Letters"
	tr -d '\n' < /tmp/letters.txt | tee /tmp/letters.txt
	EL=$(cat /tmp/letters.txt)
	grep -Evi "([$EL])" /tmp/wordleguesses.txt > /tmp/wordleguesses2.txt
fi
echo \n
echo "Are there any letters you know exist, but not the place? (Y/N)"
read answer
if [ $answer == Y ]; then
	echo "How many letters? (Enter 1-5)"
	read number_letters
	if [ $number_letters = 5 ]; then
		echo "Letter One"
		read letterA
		echo "Letter two"
		read letterB
		echo "Letter three"
		read letterC
		echo "Letter Four" 
		read letterD
		echo "Letter Five"
		read letterE
		grep -Ei "([$letterA])" /tmp/wordleguesses2.txt | grep -Ei "([$letterB])" | grep -Ei "([$letterC])" | grep -Ei "([$letterD])" | grep -Ei "([$letterE])" > /tmp/wordleguesses.txt
		elif [ $number_letters = 4 ]; then
			echo "Letter One"
			read letterA
			echo "Letter Two"
			read letterB
			echo "Letter Three"
			read letterC
			echo "Letter Four"
			read letterD
			grep -Ei "([$letterA])" /tmp/wordleguesses2.txt | grep -Ei "([$letterB])" | grep -Ei "([$letterC])" | grep -Ei "([$letterD])" > /tmp/wordleguesses.txt
			elif [ $number_letters = 3 ]; then 
				echo "Letter One" 
				read letterA
				echo "Letter Two"
				read letterB
				echo "Letter Three"
				read letterC
				grep -Ei "([$letterA])" /tmp/wordleguesses2.txt | grep -Ei "([$letterB])" | grep -Ei "([$letterC])" > /tmp/wordleguesses.txt
				elif [ $number_letters = 2 ]; then 
					echo "Letter One"
					read letterA
					echo "Letter Two" 
					read letterB
					grep -Ei "([$letterA])" /tmp/wordleguesses2.txt | grep -Ei "([$letterB])" > /tmp/wordleguesses.txt
					elif [ $number_letters = 1 ]; then
						echo "Letter One"
						read letterA
						grep -Ei "([$letterA])" /tmp/wordleguesses2.txt > /tmp/wordleguesses.txt

	fi
	elif [ $answer == N ]; then
	cp /tmp/wordleguesses2.txt /tmp/wordleguesses.txt  
	#fi
fi
echo "Your Wordle suggestions are:"
echo "============================================================="
cat /tmp/wordleguesses.txt
echo "============================================================="
rm /tmp/wordleguesses*.txt 2>&1 1> /dev/null
echo "Did you solve the word? (Y/N)"
read solve
if [ $solve == Y ]; then 
	echo "Cleaning up."
	rm /tmp/letters.txt 2>&1 1> /dev/null
	elif [ $solve == N ]; then 
	echo "Run script again."
fi
