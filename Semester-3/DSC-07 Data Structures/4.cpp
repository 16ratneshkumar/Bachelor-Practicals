/*
4. Implement a stack as an ADT using Arrays.
*/

#include <iostream>

#define MAX 100

class Stack {
    int top;
    int arr[MAX];

public:
    Stack() { top = -1; }

    bool push(int x) {
        if (top >= (MAX - 1)) {
            std::cout << "Stack Overflow\n";
            return false;
        } else {
            arr[++top] = x;
            std::cout << x << " pushed into stack\n";
            return true;
        }
    }

    int pop() {
        if (top < 0) {
            std::cout << "Stack Underflow! Cannot pop from an empty stack.\n";
            return -1;
        } else {
            int x = arr[top--];
            std::cout << x << " popped from stack\n";
            return x;
        }
    }

    int peek() {
        if (top < 0) {
            std::cout << "Stack is Empty\n";
            return 0;
        } else {
            return arr[top];
        }
    }

    bool isEmpty() {
        return (top < 0);
    }

    void display() {
        for(int i = top; i >= 0; i--) {
            std::cout << arr[i] << " ";
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