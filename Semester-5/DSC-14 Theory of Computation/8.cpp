 #include <iostream>
#include <string>
#include <stack>

using namespace std;

class PDA {
private:
    stack<char> st;
    void pushToStack(char c) {
        st.push(c);
    }

    void popFromStack() {
        if (!st.empty()) {
            char popped = st.top();
            st.pop();  
        }
    }

    void processString(string &s, int index, bool isFirstPhase) {
        if (index == s.length()) {
            if (!isFirstPhase && st.empty()) {
                cout << "String Accepted";
            } else if (isFirstPhase) {
                cout << "String Rejected ";
            } else {
                cout << "String Rejected ";
            }
            return;
        }

        char currentChar = s[index];

        if (isFirstPhase) {
            if (currentChar == 'X') {
                processString(s, index + 1, false);
            } else {
                pushToStack(currentChar);
                processString(s, index + 1, true);
            }
        } else {
            if (st.empty()) {
                cout << " String Rejected ";
                return;
            }

            char topChar = st.top();
            if (topChar == currentChar) {
                popFromStack();
                processString(s, index + 1, false);
            } else {
                cout << "String Rejected ";
                return;
            }
        }
    }

public:
    void process(string s) {
        while (!st.empty()) {
            st.pop();  
        }

        cout << "Checking string: " << s << endl;
        processString(s, 0, true);  
    }
};

int main() {
    string s;
    PDA pda;

    cout << "Enter a string of the form wXw^r (e.g., abXba): ";
    cin >> s;

    pda.process(s);

    return 0;
}

