#include <iostream>
#include <string>
using namespace std;

void q0(string w, int i);
void q1(string w, int i);
void q2(string w, int i);
void q3(string w, int i);
void q4(string w, int i);
void q5(string w, int i);
void q6(string w, int i);
void q7(string w, int i);
void q8(string w, int i);
void q9(string w, int i);
void q10(string w, int i);
void q11(string w, int i);

string firstTwo;

int main() {
    string w;
    cout << "Enter the string (a,b): ";
    cin >> w;

    if (w.length() < 4) {
        cout << "String Rejected (length < 4)";
        return 0;
    }

    firstTwo = w.substr(0, 2);
    q0(w, 0);
    return 0;
}

void q0(string w, int i) {
    if (i == w.length()) {
        cout << "String Rejected";
        return;
    }
    if (w[i] == 'a')
        q1(w, i + 1);
    else if (w[i] == 'b')
        q2(w, i + 1);
}

void q1(string w, int i) {
    if (i == w.length()) {
        cout << "String Rejected";
        return;
    }
    if (w[i] == 'a')
        q3(w, i + 1);
    else if (w[i] == 'b')
        q4(w, i + 1);
}

void q2(string w, int i) {
    if (i == w.length()) {
        cout << "String Rejected";
        return;
    }
    if (w[i] == 'a')
        q5(w, i + 1);
    else if (w[i] == 'b')
        q6(w, i + 1);
}

void q3(string w, int i) {
    if (i == w.length()) {
        cout << ((w.substr(i - 2, 2) == firstTwo) ? "String Accepted" : "String Rejected");
        return;
    }
    if (w[i] == 'a')
        q7(w, i + 1);
    else
        q8(w, i + 1);
}

void q4(string w, int i) {
    if (i == w.length()) {
        cout << ((w.substr(i - 2, 2) == firstTwo) ? "String Accepted" : "String Rejected");
        return;
    }
    if (w[i] == 'a')
        q9(w, i + 1);
    else
        q10(w, i + 1);
}

void q5(string w, int i) {
    if (i == w.length()) {
        cout << ((w.substr(i - 2, 2) == firstTwo) ? "String Accepted" : "String Rejected");
        return;
    }
    if (w[i] == 'a')
        q7(w, i + 1);
    else
        q8(w, i + 1);
}

void q6(string w, int i) {
    if (i == w.length()) {
        cout << ((w.substr(i - 2, 2) == firstTwo) ? "String Accepted" : "String Rejected");
        return;
    }
    if (w[i] == 'a')
        q9(w, i + 1);
    else
        q10(w, i + 1);
}

void q7(string w, int i) {
    if (i == w.length()) {
        cout << ((w.substr(i - 2, 2) == firstTwo) ? "String Accepted" : "String Rejected");
        return;
    }
    if (w[i] == 'a')
        q7(w, i + 1);
    else
        q8(w, i + 1);
}

void q8(string w, int i) {
    if (i == w.length()) {
        cout << ((w.substr(i - 2, 2) == firstTwo) ? "String Accepted" : "String Rejected");
        return;
    }
    if (w[i] == 'a')
        q9(w, i + 1);
    else
        q10(w, i + 1);
}

void q9(string w, int i) {
    if (i == w.length()) {
        cout << ((w.substr(i - 2, 2) == firstTwo) ? "String Accepted" : "String Rejected");
        return;
    }
    if (w[i] == 'a')
        q7(w, i + 1);
    else
        q8(w, i + 1);
}

void q10(string w, int i) {
    if (i == w.length()) {
        cout << ((w.substr(i - 2, 2) == firstTwo) ? "String Accepted" : "String Rejected");
        return;
    }
    if (w[i] == 'a')
        q9(w, i + 1);
    else
        q10(w, i + 1);
}

void q11(string w, int i) {
    cout << "String Accepted";
}
