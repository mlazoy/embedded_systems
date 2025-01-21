#include <stdio.h>
#include <unistd.h>
#include <string.h>

const char *input_msg = "Input a string up to 32-bytes long\n";
const char *exit_msg = "Exiting...\n";

void transform(char *buff_in, char *buff_out, ssize_t bytes){
    ssize_t b;
    for (b = 0; b < bytes; b++){
        if (buff_in[b] >= '0' && buff_in[b] <= '9')
            buff_out[b] = '0' + (buff_in[b] - '0' + 5) % 10;
        else if (buff_in[b] >= 'a' && buff_in[b] <= 'z') //toUpper 
            buff_out[b] = buff_in[b] - 32;
        else if (buff_in[b] >= 'A' && buff_in[b] <= 'Z') //toLower
            buff_out[b] = buff_in[b] + 32;
        else buff_out[b] = buff_in[b];
    }
    buff_out[bytes]='\n';
}

int main() {
    char buff_in[32];
    char buff_out[33];
    ssize_t bytes;

    while(1) {
        write(STDOUT_FILENO, input_msg, strlen(input_msg));
        bytes = read(STDIN_FILENO, buff_in, 32);

        if (bytes == 2 && (buff_in[0] == 'Q' || buff_in[0] == 'q')) {
            write(STDOUT_FILENO, exit_msg, strlen(exit_msg));
            return 0; //exit
        }
        else transform(buff_in, buff_out, bytes);
        write(STDOUT_FILENO, buff_out, bytes+1);

        while (bytes == 32)  // discard extra bytes
            bytes = read(STDIN_FILENO, buff_in, 32);

    }
}
