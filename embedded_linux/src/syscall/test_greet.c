#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>

#define SYS_GREET 386  

int main() {
    printf("Calling custom system call sys_greet...\n");
    int result = syscall(SYS_GREET);  
    printf("sys_greet return status: %d\n", result);
    return 0;
}
