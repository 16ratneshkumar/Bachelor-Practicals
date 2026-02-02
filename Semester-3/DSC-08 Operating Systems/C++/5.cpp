#include <iostream>
#include <fstream>
#include <string>

using namespace std;

// Function to get and display memory information
void get_memory_info() {
    ifstream meminfo("/proc/meminfo");
    string line;

    if (!meminfo.is_open()) {
        cerr << "Failed to open /proc/meminfo" << endl;
        exit(1);
    }

    cout << "\nMemory Information:\n";

    // Read the /proc/meminfo file line by line and extract memory details
    while (getline(meminfo, line)) {
        if (line.find("MemTotal") != string::npos) {
            cout << line << endl; // Total memory
        }
        if (line.find("MemFree") != string::npos) {
            cout << line << endl; // Free memory
        }
        if (line.find("MemAvailable") != string::npos) {
            cout << line << endl; // Available memory
        }
        if (line.find("Buffers") != string::npos) {
            cout << line << endl; // Buffered memory
        }
        if (line.find("Cached") != string::npos) {
            cout << line << endl; // Cached memory
        }
        if (line.find("SwapTotal") != string::npos) {
            cout << line << endl; // Total swap memory
        }
        if (line.find("SwapFree") != string::npos) {
            cout << line << endl; // Free swap memory
        }
    }

    meminfo.close();
}

int main() {
    cout << "Linux Kernel Memory Information:\n";
    
    get_memory_info(); // Get and display memory information

    return 0;
}
