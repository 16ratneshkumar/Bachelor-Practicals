/*
9. Write a program to implement Binary Search Tree as an ADT which supports the following operations: 
    1. Insert an element x 
    2. Delete an element x 
    3. Search for an element x in the BST and change its value to y and then place the node with value y at its appropriate position in the BST  
    4. Display the elements of the BST in preorder, inorder, and postorder traversal
    5. Display the elements of the BST in level by level traversal.
    6. Display the height of the BST
*/
#include <iostream>
using namespace std;

struct Node{
    Node* left;
    int data;
    Node* right;
};

Node* createNode(int value){
    Node* newNode = new Node();
    newNode->data = value;
    newNode->left = newNode->right = nullptr;
    return newNode;
}

Node* Insert(Node* root,int value){
    if (root ==nullptr){
        root = createNode(value);
    }
    else if (value < root->data){
        root->left = Insert(root->left,value);
    }else if (value > root->data){
        root->right=Insert(root->right,value);
    }
    return root;
}

Node* findmin(Node* root){
    while(root->left!=nullptr)
        root=root->left;
    return root;
}

Node* Delete(Node* root,int value){
    if (root == nullptr) return root;

    if (value < root->data) {
        root->left = Delete(root->left, value);
    }
    else if (value > root->data) {
        root->right = Delete(root->right, value);
    }
    else {
        if (root->left == nullptr) {
            Node* temp = root->right;
            delete root;
            return temp;
        } else if (root->right == nullptr) {
            Node* temp = root->left;
            delete root;
            return temp;
        }
        Node* temp = findmin(root->right);
        root->data=temp->data;
        root->right = Delete(root->right,temp->data);
    }
    return root;
}

Node* Search(Node* &root,int value){
    if (root == nullptr || root->data==value){
        return root;
    }
    if (value < root->data)
        return Search(root->left, value);
    return Search(root->right, value);
}


void preorder(Node* root){ //preorder: Root->Left->Right
    if (root != nullptr){
        cout<<root->data<<" ";
        preorder(root->left);
        preorder(root->right);
    }
}

void inorder(Node* root){  //inorder: Left->Root->Right
    if (root != nullptr){
        inorder(root->left);
        cout<<root->data<<" ";
        inorder(root->right);
    }
}

void postorder(Node* root){  //postorder: Left->Right->Root
    if (root != nullptr){
        postorder(root->left);
        postorder(root->right);
        cout<<root->data<<" ";
    }
}


#include <queue>

void levelOrder(Node* root) {
    if (root == nullptr) return;
    std::queue<Node*> q;
    q.push(root);
    while (!q.empty()) {
        Node* curr = q.front();
        q.pop();
        cout << curr->data << " ";
        if (curr->left) q.push(curr->left);
        if (curr->right) q.push(curr->right);
    }
}

int height(Node* root) {
    if (root == nullptr) return -1;
    int lh = height(root->left);
    int rh = height(root->right);
    return 1 + (lh > rh ? lh : rh);
}

Node* searchAndReplace(Node* root, int x, int y) {
    if (Search(root, x) == nullptr) return root; // Should be Search(root, x)
    root = Delete(root, x);
    root = Insert(root, y);
    return root;
}

Node* root=nullptr;

int main(){
    int choice,value, y;
    while (true){
        std::cout<<"\n1.Insert\n2.Delete\n3.Search & Replace\n4.Preorder\n5.Inorder\n6.Postorder\n7.Level Order\n8.Height\n9.Exit\nEnter Your choice:: ";
        std::cin>>choice;
        switch (choice){
            case 1:
                std::cout<<"Enter value:: "; cin>>value;
                root = Insert(root,value);
                break;
            case 2:
                std::cout<<"Enter value:: "; cin>>value;
                root = Delete(root,value);
                break;
            case 3:
                std::cout<<"Search for: "; cin>>value;
                std::cout<<"Replace with: "; cin>>y;
                root = searchAndReplace(root, value, y);
                break;
            case 4: preorder(root); cout<<endl; break;
            case 5: inorder(root); cout<<endl; break;
            case 6: postorder(root); cout<<endl; break;
            case 7: levelOrder(root); cout<<endl; break;
            case 8: cout << "Height of BST: " << height(root) << endl; break;
            case 9: cout << "Exiting..." << endl; return 0;
        }
    }
}
