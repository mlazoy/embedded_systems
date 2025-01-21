CC = gcc
CFLAGS = -g -Wall -O2
OBJ = strlen.o strcmp.o strcpy.o strcat.o
ARM = strlen.s strcmp.s strcpy.s strcat.s 

all : string_manipulation.out 

string_manipulation.out : string_manipulation.o $(OBJ)
	 $(CC) $^ -o $@

string_manipulation.o : string_manipulation.c
	$(CC) $(CFLAGS) $< -c -o $@ 

%.o: %.s 
	$(CC) $(CFLAGS) $< -c -o $@ 

clean :
	rm -f *.o *.out