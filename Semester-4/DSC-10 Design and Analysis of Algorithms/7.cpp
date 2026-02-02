// Display the data stored in a given graph using the Breadth-First Search algorithm.

#include <iostream>
#include <vector>
#include <queue>

using namespace std;

void bfs(int V, vector<vector<int>>& adj, int startNode) {
    vector<bool> visited(V, false);
    queue<int> q;

    visited[startNode] = true;
    q.push(startNode);

    cout << "Breadth First Search starting from node " << startNode << ": ";

    while (!q.empty()) {
        int curr = q.front();
        q.pop();
        cout << curr << " ";

        for (int neighbor : adj[curr]) {
            if (!visited[neighbor]) {
                visited[neighbor] = true;
                q.push(neighbor);
            }
        }
    }
    cout << endl;
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
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    int startNode;
    cout << "Enter the starting node for BFS: ";
    cin >> startNode;

    bfs(V, adj, startNode);

    return 0;
}
