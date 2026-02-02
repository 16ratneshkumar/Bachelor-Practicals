#include <iostream>
#include <string>
#include <stack>

using namespace std;

class PDA {
private:
    stack<char> st;

    void pushToStack() {
        st.push('a');
    }

    void popFromStack() {
        if (!st.empty()) {
            st.pop();
        }
    }

    void checkString(string &s, int index, bool &flag) {
        if (index == s.length()) {
            if (st.empty())
                cout << "String Accepted";
            else
                cout << "String Rejected";
            return;
        }

        char ch = s[index];

        if (ch == 'a' && flag) {
            pushToStack();
            checkString(s, index + 1, flag);
        }
        else if (ch == 'b') {
            flag = false;

            if (st.empty()) {
                cout << "String Rejected";
                return;
            } else {
                popFromStack();
                checkString(s, index + 1, flag);
            }
        }
        else {
            cout << "String Rejected";
            return;
        }
    }

public:
    void process(string s, bool &flag) {
        while (!st.empty()) {
            st.pop();
        }

        cout << "Checking string: " << s << endl;
        checkString(s, 0, flag);
    }
};

int main() {
    bool flag = true; 

    string s;
    PDA pda;

    cout << "Enter a string of 'a' and 'b': ";
    cin >> s;

    pda.process(s, flag);

    return 0;
}
