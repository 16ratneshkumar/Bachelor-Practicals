/*
6. Write a program to evaluate a prefix expression using stack.
*/

//==============================================
// Using Array.
//==============================================

#include <iostream>
#include <string>
#include <cmath>
#include <algorithm>

#define MAX 100

class ArrayStack {
    int arr[MAX];
    int topIndex;
public:
    ArrayStack() : topIndex(-1) {}
    void push(int x) {
        if (topIndex < MAX - 1) arr[++topIndex] = x;
    }
    int pop() {
        if (topIndex >= 0) return arr[topIndex--];
        return 0;
    }
    int top() {
        if (topIndex >= 0) return arr[topIndex];
        return 0;
    }
};

bool isDigit(char ch) {
    return ch >= '0' && ch <= '9';
}

int evaluatePrefix(std::string expr) {
    ArrayStack s;
    for (int i = expr.size() - 1; i >= 0; i--) {
        if (isDigit(expr[i])) {
            s.push(expr[i] - '0');
        } else if (expr[i] != ' ') {
            int op1 = s.pop();
            int op2 = s.pop();
            switch (expr[i]) {
                case '+': s.push(op1 + op2); break;
                case '-': s.push(op1 - op2); break;
                case '*': s.push(op1 * op2); break;
                case '/': s.push(op1 / op2); break;
                case '^': s.push(pow(op1, op2)); break;
            }
        }
    }
    return s.top();
}

int main() {
    std::string expr;
    std::cout << "Enter prefix expression (e.g., +*234): ";
    std::cin >> expr;
    std::cout << "Result: " << evaluatePrefix(expr) << std::endl;
    return 0;
}
