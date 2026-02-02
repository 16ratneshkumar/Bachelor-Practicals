#include <iostream>
#include <unistd.h>
#include <sys/wait.h>

using namespace std;

void execute_same_program_same_code() {
    // Parent and child will execute this function (same code)
    cout << "Executing the same program with same code.\n";
}

void execute_same_program_different_code() {
    // Parent executes a different task than child (using exec to replace child process)
    cout << "Parent is executing its task.\n";
    // Child will replace its code with a different program (e.g., "pwd" command)
    execlp("pwd", "pwd",nullptr);
    // If exec fails
    perror("exec failed");
}

int main() {
    pid_t pid = fork();  // Create a new process

    if (pid == -1) {
        // Error in creating the child process
        cerr << "Fork failed!\n";
        return 1;
    }

    if (pid == 0) {
        // Child process
        cout << "Child process (PID: " << getpid() << ") started.\n";

        // Scenario 1: Same program, same code (Child executes the same code as Parent)
        execute_same_program_same_code();
        
        // Scenario 2: Same program, different code (using exec to replace child process)
        // Child replaces its program with the "ls" command (list directory)
        execute_same_program_different_code();

    } else {
        // Parent process
        cout << "Parent process (PID: " << getpid() << ") started.\n";

        // Scenario 1: Same program, same code (Parent executes the same code as Child)
        execute_same_program_same_code();

        // Scenario 3: Parent waits for child to finish before terminating
        cout << "Parent is waiting for child to finish...\n";
        wait(NULL);  // Parent waits for the child to finish its task
        cout << "Child has finished. Parent is now terminating.\n";
    }

    return 0;
}