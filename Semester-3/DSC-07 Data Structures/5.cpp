/*
5. Implement a stack as an ADT using the Linked list ADT.
*/

#include <iostream>

struct Node {
    int data;
    Node* next;
};

class Stack {
    Node* top;

public:
    Stack() { top = nullptr; }

    void push(int x) {
        Node* newNode = new Node{x, top};
        top = newNode;
        std::cout << x << " pushed to stack\n";
    }

    int pop() {
        if (top == nullptr) {
            std::cout << "Stack Underflow! Cannot pop from an empty stack.\n";
            return -1;
        }
        Node* temp = top;
        int popped = temp->data;
        top = top->next;
        delete temp;
        std::cout << popped << " popped from stack\n";
        return popped;
    }

    int peek() {
        if (top == nullptr) return 0;
        return top->data;
    }

    bool isEmpty() {
        return top == nullptr;
    }

    void display() {
        Node* temp = top;
        while (temp != nullptr) {
            std::cout << temp->data << " ";
            temp = temp->next;
        }
        std::cout << std::endl;
    }
};

int main() {
    Stack s;
    int choice, val;
    while (true) {
        std::cout << "\n1. Push\n2. Pop\n3. Peek\n4. Display\n5. Exit\nChoice: ";
        std::cin >> choice;
        switch (choice) {
            case 1: std::cin >> val; s.push(val); break;
            case 2: std::cout << s.pop() << " popped\n"; break;
            case 3: std::cout << "Top: " << s.peek() << "\n"; break;
            case 4: s.display(); break;
            case 5: return 0;
        }
    }
}