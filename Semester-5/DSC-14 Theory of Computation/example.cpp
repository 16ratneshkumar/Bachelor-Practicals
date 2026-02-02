// Design an FA that accepts a language over S={a, b} consisting of strings that do not contain a double a.
// Write a program to simulate this FA.

#include <iostream>
using namespace std;

void State3(string w, int i);
void State2(string w, int i);
void State1(string w, int i);

void State3(string w, int i){ 
    cout << "State 3" << endl;
    if (i == w.length()) {
        cout << "String is rejected" << endl;  // String ends in a non-final state
        return;
    } else {
        if (w[i] == 'a' || w[i] == 'b')
            State3(w, i + 1);
    }   
}

void State2(string w, int i){ 
    cout << "State 2" << endl;
    if (i == w.length()) {
        cout << "String is accepted" << endl;  // Final state
        return;
    } else {
        if (w[i] == 'b')
            State1(w, i + 1);
        else if (w[i] == 'a')
            State3(w, i + 1);  
    }  
}

void State1(string w, int i){ 
    cout << "State 1" << endl;
    if (i == w.length()) {
        cout << "String is accepted" << endl;  // Final state
        return;
    } else {
        if (w[i] == 'b')
            State1(w, i + 1);
        else if (w[i] == 'a')
            State2(w, i + 1);
    }    
}

int main(){ 
    string w;
    cout<<"Enter your string"<<endl;
    cin>>w;
    State1(w, 0);
    return 0;
}