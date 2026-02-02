#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    // 1. Report Kernel Version: 'uname -r' shows the kernel version
    printf("Kernel Version:\n");
    system("uname -r");

    // 2. Report CPU Type: 'uname -m' to get the machine arcitecture ingormation
    printf("\nCPU Type:\n");
    system("uname -m");

    // 3. Report CPU Information (detailed): 'lscpu' provides detailed CPU architecture information
    printf("\nDetailed CPU Information:\n");
    system("lscpu");

    return 0;
}
