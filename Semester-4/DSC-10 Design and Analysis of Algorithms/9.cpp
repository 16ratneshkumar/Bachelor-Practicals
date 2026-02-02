// Find the Minimum Spanning Tree of a given graph using Prim's Algorithm.

#include <iostream>
#include <vector>
#include <queue>

using namespace std;

typedef pair<int, int> pii;

void primsMST(int V, vector<vector<pii>>& adj) {
    priority_queue<pii, vector<pii>, greater<pii>> pq;

    vector<int> key(V, 1e9);     
    vector<int> parent(V, -1);   
    vector<bool> inMST(V, false); 

    key[0] = 0;
    pq.push({0, 0});

    while (!pq.empty()) {
        int u = pq.top().second;
        pq.pop();

        if(inMST[u]) continue;
        inMST[u] = true;

        for (auto neighbor : adj[u]) {
            int v = neighbor.first;
            int weight = neighbor.second;

            if (!inMST[v] && weight < key[v]) {
                key[v] = weight;
                pq.push({key[v], v});
                parent[v] = u;
            }
        }
    }

    cout << "\nEdges in the Minimum Spanning Tree:\n";
    cout << "Edge \tWeight" << endl;
    int totalWeight = 0;
    for (int i = 1; i < V; ++i) {
        if(parent[i] != -1) {
            cout << parent[i] << " - " << i << " \t" << key[i] << endl;
            totalWeight += key[i];
        }
    }
    cout << "Total weight of MST: " << totalWeight << endl;
}

int main() {
    int V, E;
    cout << "Enter the number of vertices: ";
    cin >> V;
    cout << "Enter the number of edges: ";
    cin >> E;

    vector<vector<pii>> adj(V);
    cout << "Enter edges and weights (u v weight):" << endl;
    for (int i = 0; i < E; i++) {
        int u, v, w;
        cin >> u >> v >> w;
        // Adding undirected edge with weight
        adj[u].push_back({v, w});
        adj[v].push_back({u, w});
    }

    primsMST(V, adj);

    return 0;
}
