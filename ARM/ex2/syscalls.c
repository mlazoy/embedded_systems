#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>

int main(){
    int fd = open ("/dev/ttyAMA0",O_RDWR | O_NONBLOCK | O_NOCTTY);
    if (fd < 0){
        perror("Error opening serial port");
        exit(1);
    }
}