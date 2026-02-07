#include <iostream>
#include <map>
#include <string>
#include <vector>

using namespace std;

struct Node {
    map<char, Node*> children;
    vector<int> suffixIndices;

    void insertSuffix(string suffix, int index) {
        suffixIndices.push_back(index);
        if (suffix.length() > 0) {
            char firstChar = suffix[0];
            if (children.find(firstChar) == children.end()) {
                children[firstChar] = new Node();
            }
            children[firstChar]->insertSuffix(suffix.substr(1), index);
        }
    }

    void search(string pat) {
        if (pat.length() == 0) {
            for (int index : suffixIndices) {
                cout << "Pattern found at index " << index << endl;
            }
            return;
        }

        char firstChar = pat[0];
        if (children.find(firstChar) != children.end()) {
            children[firstChar]->search(pat.substr(1));
        } else {
            cout << "Pattern not found" << endl;
        }
    }
};

class SuffixTree {
    Node* root;
    string text;

public:
    SuffixTree(string txt) {
        text = txt;
        root = new Node();
        for (int i = 0; i < txt.length(); i++) {
            root->insertSuffix(txt.substr(i), i);
        }
    }

    void search(string pat) {
        root->search(pat);
    }
};

int main() {
    string txt, pat;
    cout << "Enter the text: ";
    cin >> txt;
    SuffixTree st(txt);

    cout << "Enter the pattern to search: ";
    cin >> pat;
    st.search(pat);

    return 0;
}
