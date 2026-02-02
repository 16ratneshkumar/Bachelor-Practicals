#include <iostream>
#include <string>
using namespace std;

bool checkOrder(const string &s) {
    bool seenB = false;
    bool seenC = false;

    for (char ch : s) {
        if (ch == 'a') {
            if (seenB || seenC) return false;
        }
        else if (ch == 'b') {
            seenB = true;
            if (seenC) return false;
        }
        else if (ch == 'c') {
            seenC = true;
        }
        else {
            return false;
        }
    }
    return true;
}

bool simulateTM(string tape) {
    int n = tape.size();
    if (n == 0) return false;

    if (!checkOrder(tape)) return false;

    while (true) {
        int i = 0;
        while (i < n && tape[i] != 'a') i++;

        if (i == n) {
            for (char ch : tape)
                if (ch == 'b' || ch == 'c') return false;

            return true;
        }

        tape[i] = 'X';

        int j = i + 1;
        while (j < n && tape[j] != 'b') j++;
        if (j == n) return false;
        tape[j] = 'Y';

        int k = j + 1;
        while (k < n && tape[k] != 'c') k++;
        if (k == n) return false;
        tape[k] = 'Z';
    }
}

int main() {
    string input;
    cout << "Enter a string over {a,b,c}: ";
    cin >> input;

    if (simulateTM(input))
        cout << "String Accepted ";
    else
        cout << "String Rejected ";

    return 0;
}