// Display the data stored in a given graph using the Depth-First Search algorithm.

#include <iostream>
#include <vector>

using namespace std;

void dfs(int curr, vector<vector<int>>& adj, vector<bool>& visited) {
    visited[curr] = true;
    cout << curr << " ";

    for (int neighbor : adj[curr]) {
        if (!visited[neighbor]) {
            dfs(neighbor, adj, visited);
        }
    }
}

int main() {
    int V, E;
    cout << "Enter the number of vertices: ";
    cin >> V;
    cout << "Enter the number of edges: ";
    cin >> E;

    vector<vector<int>> adj(V);
    cout << "Enter edges (u v):" << endl;
    for (int i = 0; i < E; i++) {
        int u, v;
        cin >> u >> v;
        // Adding edge u-v (Undirected)
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    int startNode;
    cout << "Enter the starting node for DFS: ";
    cin >> startNode;

    vector<bool> visited(V, false);
    cout << "Depth First Search starting from node " << startNode << ": ";
    dfs(startNode, adj, visited);
    cout << endl;

    return 0;
}
