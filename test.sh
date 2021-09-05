#!/bin/sh
function GNLTEST()																# perform test for every BUFFER_SIZE in arg
{
	for arg; do
		local valgrindleaks=0
		local valgrinderrors=0
		gcc -Wall -Werror -Wextra -D BUFFER_SIZE=$arg ../$file ../get_next_line.h ../get_next_line_utils.c ./src/main.c
		for files in `ls ./tests`; do
			./a.out "./tests/$files" > ./result/result_$files && [ $arg -le 0 ] && diff ./result/result_$files ./tests/empty.txt >> diff.txt || diff ./result/result_$files ./tests/$files >> diff.txt
			valgrind -s --leak-check=full --show-leak-kinds=all --track-origins=yes ./a.out "./tests/$files" 1> /dev/null 2> valgrindresult.txt
			valgrindleaks=$(grep "in use at exit:" "valgrindresult.txt" | awk '{print $6}' | xargs -I vl echo "vl+$valgrindleaks" | bc)
			valgrinderrors=$(cat valgrindresult.txt | awk 'END {print $4}' | xargs -I ve echo "ve+$valgrinderrors" | bc)
		done
		./a.out "" "42" > ./result/result_wrong_fd.txt && diff ./result/result_wrong_fd.txt ./tests/empty.txt >> diff.txt
		valgrind -s --leak-check=full --show-leak-kinds=all --track-origins=yes ./a.out "" "42" 1> /dev/null 2> valgrindresult.txt
		valgrindleaks=$(grep "in use at exit:" "valgrindresult.txt" | awk '{print $6}' | xargs -I vl echo "vl+$valgrindleaks" | bc)
		valgrinderrors=$(cat valgrindresult.txt | awk 'END {print $4}' | xargs -I ve echo "ve+$valgrinderrors" | bc)
		local res=$(cat diff.txt | wc -l)
		echo -e "\n[BUFFER_SIZE = $arg]" | tee -a log
		if [ $res -eq 0 ]; then
			echo -e "diff \033[32mOK\033[0m" | tee -a log
			rm diff.txt
		else
			echo -e "diff \033[31mKO\033[0m" | tee -a log
		fi
		if [ $valgrindleaks -eq 0 ] && [ $valgrinderrors -eq 0 ]; then
			echo -e "valgrind leaks \033[32mOK\033[0m, valgrind errors \033[32mOK\033[0m" | tee -a log
			rm valgrindresult.txt
		elif [ $valgrindleaks -eq 0 ] && [ $valgrinderrors -ne 0 ]; then
			echo -e "valgrind leaks \033[32mOK\033[0m, valgrind errors \033[31mKO\033[0m ($valgrinderrors)" | tee -a log
		elif [ $valgrindleaks -ne 0 ] && [ $valgrinderrors -eq 0 ]; then
			echo -e "valgrind leaks \033[31mKO\033[0m ($valgrindleaks), valgrind errors \033[32mOK\033[0m" | tee -a log
		elif [ $valgrindleaks -ne 0 ] && [ $valgrinderrors -ne 0 ]; then
			echo -e "valgrind leaks \033[31mKO\033[0m ($valgrindleaks), valgrind errors \033[31mKO\033[0m ($valgrinderrors)" | tee -a log
		fi
		rm a.out
	done
}

rm log a.out valgrindresult.txt diff.txt vgcore.* result/* ../get_next_line.h.gch 2> /dev/null			# clean

if [ $1 == "clean" ]; then
	echo "Cleaning the mess..."
	sleep 0.38
	clear
	exit 0
elif [ $1 == "--help" ]; then													# help
	echo """
	This is a bash script for testing the GNL 42 Project. It's a very simple script so please do your own tests and don't think than this test is enought.
	My script use my main to read and print entirely all files in the directory tests with your GNL.
	Result of this reading are stored in the directory result as result_filename. It just does a diff beetween original file and result from your GNL.
	It also perform valgrind test to detect memory leaks and some errors. The result of the test is stored in log.

	The normal usage is ./test [GNLfilename]. The test directory need to be in your GNL directory.
	                    ./test [--help] to display this help.
	                    ./test [clean] to clean the mess.
	"""
	exit 0
fi

file=$1
norm=$(python -m norminette ../$file ../get_next_line.h ../get_next_line_utils.c | grep -c Error)

echo "TEST GNL" | tee -a log
if [ $norm -eq 0 ]; then
	echo -e "\nnorm \033[32mOK\033[0m" | tee -a log
else
	echo -e "\nnorm \033[31mKO\033[0m" | tee -a log
fi
for bs in `seq -1 10`; do														# call GNL_TEST with a lot of BUFFER_SIZE
	GNLTEST "$bs"
done
GNLTEST "100" "1000" "10000"													# call GNL_TEST with precise BUFFER_SIZE
