/*
8. Implement Queue as an ADT using the circular linked list ADT.  
*/

#include <iostream>

struct Node {
    int data;
    Node* next;
    Node(int val) : data(val), next(nullptr) {}
};

class Queue {
    Node* tail;
public:
    Queue() : tail(nullptr) {}

    void enqueue(int x) {
        Node* newNode = new Node(x);
        if (tail == nullptr) {
            tail = newNode;
            tail->next = tail;
        } else {
            newNode->next = tail->next;
            tail->next = newNode;
            tail = newNode;
        }
        std::cout << x << " enqueued\n";
    }

    void dequeue() {
        if (tail == nullptr) {
            std::cout << "Queue Underflow\n";
            return;
        }
        Node* head = tail->next;
        if (head == tail) {
            tail = nullptr;
        } else {
            tail->next = head->next;
        }
        std::cout << head->data << " dequeued\n";
        delete head;
    }

    void peek() {
        if (tail == nullptr) return;
        std::cout << "Front: " << tail->next->data << "\n";
    }

    void display() {
        if (tail == nullptr) return;
        Node* temp = tail->next;
        do {
            std::cout << temp->data << " ";
            temp = temp->next;
        } while (temp != tail->next);
        std::cout << std::endl;
    }
};

int main() {
    Queue q;
    int choice, val;
    while (true) {
        std::cout << "\n1. Enqueue\n2. Dequeue\n3. Peek\n4. Display\n5. Exit\nChoice: ";
        std::cin >> choice;
        switch (choice) {
            case 1: std::cin >> val; q.enqueue(val); break;
            case 2: q.dequeue(); break;
            case 3: q.peek(); break;
            case 4: q.display(); break;
            case 5: return 0;
        }
    }
}