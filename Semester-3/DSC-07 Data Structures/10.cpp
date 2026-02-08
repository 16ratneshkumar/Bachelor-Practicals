/*
10. Write a program to implement a balanced search tree as an ADT.
(Implementing AVL Tree as a Balanced Search Tree)
*/

#include <iostream>
#include <algorithm>

struct Node {
    int data;
    Node *left, *right;
    int height;
};

int getHeight(Node* n) { return n ? n->height : 0; }
int getBalance(Node* n) { return n ? getHeight(n->left) - getHeight(n->right) : 0; }

Node* rotateRight(Node* y) {
    Node* x = y->left;
    Node* T2 = x->right;
    x->right = y;
    y->left = T2;
    y->height = std::max(getHeight(y->left), getHeight(y->right)) + 1;
    x->height = std::max(getHeight(x->left), getHeight(x->right)) + 1;
    return x;
}

Node* rotateLeft(Node* x) {
    Node* y = x->right;
    Node* T2 = y->left;
    y->left = x;
    x->right = T2;
    x->height = std::max(getHeight(x->left), getHeight(x->right)) + 1;
    y->height = std::max(getHeight(y->left), getHeight(y->right)) + 1;
    return y;
}

Node* insert(Node* node, int data) {
    if (!node) return new Node{data, nullptr, nullptr, 1};
    if (data < node->data) node->left = insert(node->left, data);
    else if (data > node->data) node->right = insert(node->right, data);
    else return node;

    node->height = 1 + std::max(getHeight(node->left), getHeight(node->right));
    int balance = getBalance(node);

    if (balance > 1 && data < node->left->data) return rotateRight(node);
    if (balance < -1 && data > node->right->data) return rotateLeft(node);
    if (balance > 1 && data > node->left->data) {
        node->left = rotateLeft(node->left);
        return rotateRight(node);
    }
    if (balance < -1 && data < node->right->data) {
        node->right = rotateRight(node->right);
        return rotateLeft(node);
    }
    return node;
}

void inorder(Node* root) {
    if (root) {
        inorder(root->left);
        std::cout << root->data << " ";
        inorder(root->right);
    }
}

int main() {
    Node* root = nullptr;
    int choice, val;
    while (true) {
        std::cout << "\n1. Insert\n2. Inorder\n3. Exit\nChoice: ";
        std::cin >> choice;
        if (choice == 1) { std::cin >> val; root = insert(root, val); }
        else if (choice == 2) { 
            std::cout << "Inorder Traversal: ";
            inorder(root); 
            std::cout << std::endl; 
        }
        else {
            std::cout << "Exiting..." << std::endl;
            break;
        }
    }
    return 0;
}