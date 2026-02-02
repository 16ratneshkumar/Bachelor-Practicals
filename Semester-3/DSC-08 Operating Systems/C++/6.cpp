// Copy files using system calls

#include <iostream>
#include <fcntl.h>   // For open()
#include <unistd.h>  // For read(), write(), close()
#include <sys/types.h>  // For types used in system calls
#include <sys/stat.h>   // For file permissions

using namespace std;

void copy_file(const char* source, const char* destination) {
    // Open the source file in read-only mode
    int source_fd = open(source, O_RDONLY);
    if (source_fd == -1) {
        perror("Failed to open source file");
        exit(1);
    }

    // Open the destination file in write-only mode (create it if it doesn't exist)
    int dest_fd = open(destination, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
    if (dest_fd == -1) {
        perror("Failed to open destination file");
        close(source_fd);
        exit(1);
    }

    char buffer[1024];
    ssize_t bytes_read, bytes_written;

    // Read from the source file and write to the destination file
    while ((bytes_read = read(source_fd, buffer, sizeof(buffer))) > 0) {
        bytes_written = write(dest_fd, buffer, bytes_read);
        if (bytes_written != bytes_read) {
            perror("Error writing to destination file");
            close(source_fd);
            close(dest_fd);
            exit(1);
        }
    }

    if (bytes_read == -1) {
        perror("Error reading from source file");
    }

    // Close both source and destination files
    close(source_fd);
    close(dest_fd);

    cout << "File copied successfully from " << source << " to " << destination << endl;
}

int main() {
    const char* source = "source.txt";         // Specify source file name
    const char* destination = "destination.txt"; // Specify destination file name

    // Copy the file
    copy_file(source, destination);

    return 0;
}
