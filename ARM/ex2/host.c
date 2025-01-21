#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <stdio.h>

char buff[64];
char results[2];

const char *serial_port = "/dev/ttys004";

int main() {
    ssize_t bytes;
    struct termios options;
    int fd;
    char res, freq;

    fd = open(serial_port, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        perror("Error openning serial port");
        exit(1);
    }

    // Get current serial port settings
    if (tcgetattr(fd, &options) < 0) {
        perror("Error getting serial port attributes");
        close(fd);
        exit(1);
    }

    options.c_lflag = 0;
    options.c_lflag |= ICANON; 
    options.c_cflag |= (CLOCAL | CREAD | CS8);
    options.c_cflag &= ~CSTOPB;
    options.c_cc[VMIN] = 1; 
    options.c_cc[VTIME] = 0; 

    if(cfsetispeed(&options, B115200) < 0 || cfsetospeed(&options, B115200) < 0) {
        perror("Error setting baudrate\n");
        exit(1);
    }
    
    if (tcsetattr(fd, TCSANOW, &options) < 0){
        perror("Error applying termios configurations");
        exit(1);
    }  
    //clear terminal buffer
    tcflush(fd, TCIOFLUSH);

    printf("Input a string up to 64-bytes long:\n");
    bytes = read(STDIN_FILENO, buff, sizeof(buff));
    if (bytes < 0) {
        perror("Error reading input string");
        exit(1);
    }
    if (bytes == 64) {
        buff[63] = '\0'; //discard rest bytes
        tcflush(STDIN_FILENO, TCIOFLUSH);
        printf("Input string exceeded 64-bytes! Rest will be ignored\n", STDERR_FILENO);
    }
    
    // transfer input over serial port
    if (write(fd, buff, bytes) < 0) {
        perror("Error writing to serial port");
        exit(1);
    }
    printf("Bytes sent to guest successfully\n");

    // get result from serial port
    printf("Waiting for results...\n");
    sleep(1);
    if (read(fd, results, 4) < 0) {
        perror("Error reading results");
        exit(1);
    }
    res = results[0];
    freq = results[1];
    
    printf("The most frequent charachter is: %c and it appeared %c times.\n", res, freq);

    close(fd);
    return 0;
}
