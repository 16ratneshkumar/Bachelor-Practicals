/*
6. Write a program to evaluate a prefix expression using stack.
*/

//==============================================
// Using Linked List.
//==============================================

#include <iostream>
#include <string>
#include <cmath>

struct Node {
    int data;
    Node* next;
};

class LinkedStack {
    Node* topNode;
public:
    LinkedStack() : topNode(nullptr) {}
    void push(int x) {
        Node* newNode = new Node{x, topNode};
        topNode = newNode;
    }
    int pop() {
        if (topNode == nullptr) return 0;
        Node* temp = topNode;
        int data = temp->data;
        topNode = topNode->next;
        delete temp;
        return data;
    }
    int top() {
        if (topNode != nullptr) return topNode->data;
        return 0;
    }
};

bool isDigit(char ch) {
    return ch >= '0' && ch <= '9';
}

int evaluatePrefix(std::string expr) {
    LinkedStack s;
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
