#include <iostream>
#include <string>
using namespace std;

string incrementTM(string tape) {
    tape = "B" + tape + "B";
    int head = 1;           
    int n = tape.size();
    string state = "q0";

    while (true) {
        if (state == "q0") {
            if (tape[head] == '0' || tape[head] == '1') {
                head++; 
            } 
            else if (tape[head] == 'B') {
                head--;      
                state = "q1";
            }
        }
        else if (state == "q1") {
            if (tape[head] == '0') {
                tape[head] = '1'; 
                state = "ACCEPT";
            }
            else if (tape[head] == '1') {
                tape[head] = '0'; 
                head--;
            }
            else if (tape[head] == 'B') {
                tape[head] = '1'; 
                state = "ACCEPT";
            }
        }
        else if (state == "ACCEPT") {
            break;
        }
    }

    int start = tape.find_first_not_of('B');
    int end   = tape.find_last_not_of('B');
    return tape.substr(start, end - start + 1);
}

int main() {
    string input;
    cout << "Enter a binary number: ";
    cin >> input;

    for (char c : input) {
        if (c != '0' && c != '1') {
            cout << "Invalid input!\n";
            return 0;
        }
    }

    string result = incrementTM(input);
    cout << "Incremented binary: " << result << "\n";

    return 0;
}