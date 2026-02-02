// Write a program to determine the shortest path from a given node s to the other nodes of a graph using the Dijkstra’s algorithm.

#include <iostream>
#include <vector>
#include <queue>

using namespace std;

typedef pair<int, int> pii;

void dijkstra(int V, vector<vector<pii>>& adj, int startNode) {
    priority_queue<pii, vector<pii>, greater<pii>> pq;

    vector<int> dist(V, 1e9);

    dist[startNode] = 0;
    pq.push({0, startNode});

    while (!pq.empty()) {
        int d = pq.top().first;
        int u = pq.top().second;
        pq.pop();

        if (d > dist[u]) continue;

        for (auto neighbor : adj[u]) {
            int v = neighbor.first;
            int weight = neighbor.second;

            if (dist[u] + weight < dist[v]) {
                dist[v] = dist[u] + weight;
                pq.push({dist[v], v});
            }
        }
    }

    cout << "\nShortest distances from node " << startNode << ":\n";
    cout << "Node \tDistance" << endl;
    for (int i = 0; i < V; i++) {
        cout << i << " \t";
        if (dist[i] == 1e9) cout << "INF" << endl;
        else cout << dist[i] << endl;
    }
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
        adj[u].push_back({v, w});
        adj[v].push_back({u, w}); // Assuming undirected
    }

    int startNode;
    cout << "Enter the starting node: ";
    cin >> startNode;

    dijkstra(V, adj, startNode);

    return 0;
}
