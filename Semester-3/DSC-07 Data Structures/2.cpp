/* 
2. Write a program to implement doubly linked list as an ADT that supports the following operations: 
    1. Insert an element x at the beginning of the doubly linked list
    2. Insert an element x at ith position in the doubly linked list
    3. Insert an element x at the end of the doubly linked list 
    4. Remove an element from the beginning of the doubly linked list 
    5. Remove an element from ith position in the doubly linked list.
    6. Remove an element from the end of the doubly linked list
    7. Search for an element x in the doubly linked list.
    8. Concatenate two doubly linked lists.
*/

#include <iostream>

struct Node{
    Node* prev;
    int data;
    Node* next;
};


void insert_at_begin(Node* &head,int value){
    Node* newnode= new Node();
    newnode->prev=nullptr;
    newnode->data=value;
    newnode->next=head;
    if (head!=nullptr){
        head->prev = newnode;
    }
    head=newnode;
    std::cout<<head->data<<"->"<<"Inserted"<<std::endl;
}

void insert_at_end(Node* &head,int value){
    if (head==nullptr){
        insert_at_begin(head,value);
        return;
    }
    Node* newnode= new Node();
    newnode->prev=nullptr;
    newnode->data=value;
    newnode->next=nullptr;
    Node* temp=head;
    while (temp->next!=nullptr){
        temp=temp->next;
    }
    if (temp!=nullptr){
        temp->next=newnode;
        newnode->prev=temp;
    }
    std::cout<<newnode->data<<"->"<<"Inserted"<<std::endl;
}

void remove_from_begin(Node* &head){
    if (head==nullptr){
        std::cout<<"List is empty!"<<std::endl;
        return;
    }
    Node* temp=head;
    head=head->next;
    head->prev=nullptr;
    std::cout<<temp->data<<"->"<<"Deleted"<<std::endl;
    delete temp;
}

void remove_from_end(Node* &head){
    if (head==nullptr){
        std::cout<<"List is empty!"<<std::endl;
        return;
    }
    if (head->next==nullptr){
        std::cout<<head->data<<"->"<<"Deleted"<<std::endl;
        delete head;
        head=nullptr;
        return;
    }
    Node* temp=head;
    while (temp->next!=nullptr){
        temp=temp->next;
    }
    temp->prev->next=nullptr;
    std::cout<<temp->data<<"->"<<"Deleted"<<std::endl;
    delete temp;

}

void insert_at_postion(Node* &head, int value, int position) {
    if (position == 1) {
        insert_at_begin(head, value);
        return;
    }
    Node* temp = head;
    for (int i = 1; i < position - 1 && temp != nullptr; i++) {
        temp = temp->next;
    }
    if (temp == nullptr) {
        std::cout << "Position out of bound" << std::endl;
        return;
    }
    Node* newnode = new Node();
    newnode->data = value;
    newnode->next = temp->next;
    newnode->prev = temp;
    if (temp->next != nullptr) {
        temp->next->prev = newnode;
    }
    temp->next = newnode;
    std::cout << value << "->Inserted at position " << position << std::endl;
}

void remove_from_postion(Node* &head, int position) {
    if (head == nullptr) {
        std::cout << "List is empty!" << std::endl;
        return;
    }
    if (position == 1) {
        remove_from_begin(head);
        return;
    }
    Node* temp = head;
    for (int i = 1; i < position && temp != nullptr; i++) {
        temp = temp->next;
    }
    if (temp == nullptr) {
        std::cout << "Position out of bound" << std::endl;
        return;
    }
    if (temp->next != nullptr) {
        temp->next->prev = temp->prev;
    }
    if (temp->prev != nullptr) {
        temp->prev->next = temp->next;
    }
    std::cout << temp->data << "->Deleted" << std::endl;
    delete temp;
}

Node* search(Node* head, int value) {
    Node* temp = head;
    while (temp != nullptr) {
        if (temp->data == value) {
            return temp;
        }
        temp = temp->next;
    }
    return nullptr;
}

void concatenate(Node* &head1, Node* head2) {
    if (head1 == nullptr) {
        head1 = head2;
        return;
    }
    if (head2 == nullptr) return;
    Node* temp = head1;
    while (temp->next != nullptr) {
        temp = temp->next;
    }
    temp->next = head2;
    head2->prev = temp;
    std::cout << "Lists concatenated successfully!" << std::endl;
}

void display_forward(Node* head){
    if (head ==nullptr){
        std::cout<<"List is empty!"<<std::endl;
        return;
    }
    Node* temp =head;
    while(temp!=nullptr){
        std::cout<<temp->data<<"->";
        temp=temp->next;
    }
    std::cout<<"Null"<<std::endl;
}

void display_backword(Node* head){
    if (head ==nullptr){
        std::cout<<"List is empty!"<<std::endl;
        return;
    }
    Node* temp =head;
    while(temp->next!=nullptr){
        temp=temp->next;
    }
    while(temp!=nullptr){
        std::cout<<temp->data<<"->";
        temp=temp->prev;
    }
    std::cout<<"Null"<<std::endl;
}


Node* head = nullptr;
Node* head2 = nullptr;

int main(){
    int choice,value,position;
    while (true){
        std::cout<<"\n1.Insert at begin\n2.Insert at position\n3.Insert at end\n4.Remove from begin\n5.Remove from position\n6.Remove from end\n7.Search\n8.Concatenate\n9.Display Forward\n10.Display Backward\n11.Exit\nEnter Your choice:: ";
        std::cin>>choice;
        switch (choice){
            case 1:
                std::cout<<"Enter value:: ";
                std::cin>>value;
                insert_at_begin(head,value);
                break;
            case 2:
                std::cout<<"Enter value:: ";
                std::cin>>value;
                std::cout<<"Enter position:: ";
                std::cin>>position;
                insert_at_postion(head,value,position);
                break;
            case 3:
                std::cout<<"Enter value:: ";
                std::cin>>value;
                insert_at_end(head,value);
                break;
            case 4:
                remove_from_begin(head);
                break;
            case 5:
                std::cout<<"Enter position:: ";
                std::cin>>position;
                remove_from_postion(head,position);
                break;
            case 6:
                remove_from_end(head);
                break;
            case 7:
                std::cout<<"Enter value:: ";
                std::cin>>value;
                if (search(head,value)) std::cout<<"Element "<<value<<" found in the list!\n";
                else std::cout<<"Element "<<value<<" not found!\n";
                break;
            case 8:
                int n, val;
                std::cout << "Enter number of elements for second list: ";
                std::cin >> n;
                head2 = nullptr;
                for (int i = 0; i < n; i++) {
                    std::cout << "Enter value: ";
                    std::cin >> val;
                    insert_at_end(head2, val);
                }
                concatenate(head, head2);
                std::cout << "Lists concatenated!" << std::endl;
                break;
            case 9:
                display_forward(head);
                break;
            case 10:
                display_backword(head);
                break;
            case 11:
                return 0;
        }
    }
}

