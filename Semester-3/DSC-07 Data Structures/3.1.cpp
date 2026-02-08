/*
3. Write a program to implement circular linked list as an ADT which supports the following operations:
    1. Insert an element x at the front of the circularly linked list 
    2. Insert an element x after an element y in the circularly linked list 
    3. Insert an element x at the back of the circularly linked list 
    4. Remove an element from the back of the circularly linked list 
    5. Remove an element from the front of the circularly linked list 
    6. Remove an element x from the circularly linked list 
    7. Search for an element x in the circularly linked list and return its pointer
    8. Concatenate two circularly linked lists. 
*/

//==============================================
// Using Singly Linked List.
//==============================================

#include <iostream>

struct Node {
    int data;
    Node* next;
};

void insert_front(Node* &head, int x) {
    Node* newNode = new Node{x, nullptr};
    if (head == nullptr) {
        head = newNode;
        newNode->next = head;
    } else {
        Node* temp = head;
        while (temp->next != head) temp = temp->next;
        newNode->next = head;
        temp->next = newNode;
        head = newNode;
    }
    std::cout << "Element " << x << " inserted at front." << std::endl;
}

void insert_back(Node* &head, int x) {
    Node* newNode = new Node{x, nullptr};
    if (head == nullptr) {
        head = newNode;
        newNode->next = head;
    } else {
        Node* temp = head;
        while (temp->next != head) temp = temp->next;
        temp->next = newNode;
        newNode->next = head;
    }
    std::cout << "Element " << x << " inserted at back." << std::endl;
}

void insert_after(Node* head, int y, int x) {
    if (head == nullptr) return;
    Node* temp = head;
    do {
        if (temp->data == y) {
            Node* newNode = new Node{x, temp->next};
            temp->next = newNode;
            std::cout << "Element " << x << " inserted after " << y << "." << std::endl;
            return;
        }
        temp = temp->next;
    } while (temp != head);
    std::cout << "Element " << y << " not found." << std::endl;
}

void remove_front(Node* &head) {
    if (head == nullptr) {
        std::cout << "List is empty!" << std::endl;
        return;
    }
    if (head->next == head) {
        std::cout << "Element " << head->data << " removed from front." << std::endl;
        delete head;
        head = nullptr;
    } else {
        Node* temp = head;
        Node* last = head;
        while (last->next != head) last = last->next;
        head = head->next;
        last->next = head;
        std::cout << "Element " << temp->data << " removed from front." << std::endl;
        delete temp;
    }
}

void remove_back(Node* &head) {
    if (head == nullptr) {
        std::cout << "List is empty!" << std::endl;
        return;
    }
    if (head->next == head) {
        std::cout << "Element " << head->data << " removed from back." << std::endl;
        delete head;
        head = nullptr;
    } else {
        Node* temp = head;
        Node* prev = nullptr;
        while (temp->next != head) {
            prev = temp;
            temp = temp->next;
        }
        prev->next = head;
        std::cout << "Element " << temp->data << " removed from back." << std::endl;
        delete temp;
    }
}

void remove_x(Node* &head, int x) {
    if (head == nullptr) {
        std::cout << "List is empty!" << std::endl;
        return;
    }
    Node* temp = head;
    Node* prev = nullptr;
    if (head->data == x) {
        remove_front(head);
        return;
    }
    do {
        prev = temp;
        temp = temp->next;
        if (temp->data == x) {
            prev->next = temp->next;
            std::cout << "Element " << x << " removed from list." << std::endl;
            delete temp;
            return;
        }
    } while (temp != head);
    std::cout << "Element " << x << " not found." << std::endl;
}

Node* search(Node* head, int x) {
    if (head == nullptr) return nullptr;
    Node* temp = head;
    do {
        if (temp->data == x) return temp;
        temp = temp->next;
    } while (temp != head);
    return nullptr;
}

void concatenate(Node* &head1, Node* head2) {
    if (head1 == nullptr) { head1 = head2; return; }
    if (head2 == nullptr) return;
    Node* last1 = head1;
    while (last1->next != head1) last1 = last1->next;
    Node* last2 = head2;
    while (last2->next != head2) last2 = last2->next;
    last1->next = head2;
    last2->next = head1;
    std::cout << "Circular lists concatenated successfully!" << std::endl;
}

void display(Node* head) {
    if (head == nullptr) {
        std::cout << "List is empty." << std::endl;
        return;
    }
    Node* temp = head;
    do {
        std::cout << temp->data << " -> ";
        temp = temp->next;
    } while (temp != head);
    std::cout << "(head)" << std::endl;
}

int main() {
    Node* head = nullptr;
    int choice, x, y;
    while (true) {
        std::cout << "\n1. Insert Front\n2. Insert After\n3. Insert Back\n4. Remove Front\n5. Remove Back\n6. Remove X\n7. Search\n8. Concatenate\n9. Display\n10. Exit\nChoice: ";
        std::cin >> choice;
        switch (choice) {
            case 1: std::cin >> x; insert_front(head, x); break;
            case 2: std::cin >> y >> x; insert_after(head, y, x); break;
            case 3: std::cin >> x; insert_back(head, x); break;
            case 4: remove_front(head); break;
            case 5: remove_back(head); break;
            case 6: std::cin >> x; remove_x(head, x); break;
            case 7: 
                std::cin >> x; 
                if (search(head, x)) std::cout << "Element " << x << " Found in list.\n"; 
                else std::cout << "Element " << x << " Not Found\n"; 
                break;
            case 8: {
                Node* head2 = nullptr;
                int n, val;
                std::cout << "Elements for 2nd list: "; std::cin >> n;
                while(n--) { std::cin >> val; insert_back(head2, val); }
                concatenate(head, head2);
                break;
            }
            case 9: display(head); break;
            case 10: std::cout << "Exiting..." << std::endl; return 0;
        }
    }
}