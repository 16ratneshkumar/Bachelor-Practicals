// Write a program to implement first-fit, best-fit and worst-fit allocation strategies.
#include <iostream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;

void display(const vector<pair<string, int>>& memory) {
    int count = 1;
    cout << "Memory Status:" << endl;
    for (const auto& frame : memory) {
        cout << "Frame: " << count << " | Process: " << frame.first << " | Size: " << frame.second << endl;
        count++;
    }
}

void firstFit(int noOfFrames, vector<pair<string, int>>& memory, const pair<string, int>& process) {
    bool flag = false;
    for (int i = 0; i < noOfFrames; i++) {
        if (memory[i].first == "free" && memory[i].second >= process.second) {
            memory[i].first = process.first;
            display(memory);
            flag = true;
            break;
        }
    }
    if (!flag) {
        cout << "\nYou Have Not Enough Space To Run New Process" << endl;
    }
}

void bestFit(int noOfFrames, vector<pair<string, int>>& memory, const pair<string, int>& process) {
    int flag = -1;
    for (int i = 0; i < noOfFrames; i++) {
        if (memory[i].first == "free" && memory[i].second >= process.second) {
            if (flag == -1 || memory[i].second < memory[flag].second) {
                flag = i;
            }
        }
    }
    if (flag != -1) {
        memory[flag].first = process.first;
        display(memory);
    } else {
        cout << "\nYou do not have enough space to run the new process." << endl;
    }
}

void worstFit(int noOfFrames, vector<pair<string, int>>& memory, const pair<string, int>& process) {
    int flag = -1;
    for (int i = 0; i < noOfFrames; i++) {
        if (memory[i].first == "free" && memory[i].second >= process.second) {
            if (flag == -1 || memory[i].second > memory[flag].second) {
                flag = i;
            }
        }
    }
    if (flag != -1) {
        memory[flag].first = process.first;
        display(memory);
    } else {
        cout << "\nYou do not have enough space to run the new process." << endl;
    }
}

int main() {
    vector<pair<string, int>> memory;
    while (true) {
        cout << "Enter memory type (used/free) and value, or 'q' to quit: ";
        string input;
        getline(cin, input);
        if (input == "q") {
            break;
        }
        istringstream iss(input);
        string memoryType;
        int value;
        iss >> memoryType >> value;
        memory.push_back({memoryType, value});
    }

    cout << "Enter process name and value: ";
    string processName, processValue;
    cin >> processName >> processValue;
    int processValueInt = stoi(processValue);

    pair<string, int> process = {processName, processValueInt};

    cout << "Main Menu \n1. First Fit\n2. Best Fit\n3. Worst Fit\nEnter your Choice:: ";
    int choice;
    cin >> choice;

    if (choice == 1) {
        firstFit(memory.size(), memory, process);
    } else if (choice == 2) {
        bestFit(memory.size(), memory, process);
    } else {
        worstFit(memory.size(), memory, process);
    }

    return 0;
}