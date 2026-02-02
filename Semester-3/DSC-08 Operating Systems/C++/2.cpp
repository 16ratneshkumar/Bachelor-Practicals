#include <iostream>
#include <unistd.h>
#include <sys/wait.h>

int main() {
    std::cout << "Process Control Demonstration:\n";
    pid_t pid = fork();
    if (pid == 0) {
        std::cout << "Child process running. PID: " << getpid() << std::endl;
        sleep(2); 
        std::cout << "Child process finished.\n";
        exit(0);
    } else if (pid > 0) {
        std::cout << "Parent process running. PID: " << getpid() << std::endl;
        std::cout << "Waiting for child process to finish...\n";
        wait(nullptr);
    } else {
        std::cerr << "Fork failed.\n";
        return 1;
    }
    std::cout << "Listing current processes using 'ps':\n";
    system("ps"); 
    std::cout << "Demonstrating kill:"<<getpid()<<"\n";
    kill(getpid(), SIGTERM);
}





    