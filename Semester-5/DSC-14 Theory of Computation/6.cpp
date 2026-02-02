#include <iostream>
#include <string>
using namespace std;

//-----------------------------------------------------------
// AUTOMATON A (a+b)+
//-----------------------------------------------------------
bool A_q1(string w, int i);
bool A_q2(string w, int i);
bool A_q3(string w, int i);

bool A_q1(string w, int i){
    if(i==w.length()) return false;
    if(w[i]=='a') return A_q2(w,i+1);
    if(w[i]=='b') return A_q3(w,i+1);
    return false;
}
bool A_q2(string w, int i){
    if(i==w.length()) return true;
    if(w[i]=='a') return A_q2(w,i+1);
    if(w[i]=='b') return A_q3(w,i+1);
    return false;
}
bool A_q3(string w, int i){
    if(i==w.length()) return true;
    if(w[i]=='a') return A_q2(w,i+1);
    if(w[i]=='b') return A_q3(w,i+1);
    return false;
}
bool acceptA(string w){
    return A_q1(w,0);
}

//-----------------------------------------------------------
// AUTOMATON B (a+b)b*
//-----------------------------------------------------------
bool B_q1(string w, int i);
bool B_q2(string w, int i);

bool B_q1(string w, int i){
    if(i==w.length()) return false;   // must end with b
    if(w[i]=='a') return B_q1(w,i+1);
    if(w[i]=='b') return B_q2(w,i+1);
    return false;
}
bool B_q2(string w, int i){
    if(i==w.length()) return true;    // ends with b
    if(w[i]=='a') return B_q1(w,i+1);
    if(w[i]=='b') return B_q2(w,i+1);
    return false;
}
bool acceptB(string w){
    return B_q1(w,0);
}

//-----------------------------------------------------------
// CONCATENATION A·B
//-----------------------------------------------------------
bool concatAB(string w){
    int n = w.length();
    for(int split=0; split<=n; split++){
        string x = w.substr(0,split);
        string y = w.substr(split);
        if(acceptA(x) && acceptB(y))
            return true;
    }
    return false;
}

//-----------------------------------------------------------
// MAIN MENU UPDATED
//-----------------------------------------------------------
int main(){
    string w;
    int ch;

    cout << "Enter string (a,b only): ";
    cin >> w;

    cout << "\n---- MENU ----\n";
    cout << "1. Union\n";
    cout << "2.Intersection\n";
    cout << "3.Concatenation\n";
    cout << "4. Exit\n";
    cout << "Enter choice: ";
    cin >> ch;

    bool result = false;

    switch(ch){
        case 1: result = (acceptA(w) || acceptB(w)); break;
        case 2: result = (acceptA(w) && acceptB(w)); break;
        case 3: result = concatAB(w); break;
        case 4: return 0;
        default: cout << "Invalid choice!"; return 0;
    }

    if(result) cout << "String Accepted";
    else       cout << "String Rejected";

    return 0;
}

