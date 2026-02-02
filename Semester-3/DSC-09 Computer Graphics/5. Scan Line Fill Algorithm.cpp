#include <graphics.h>
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

struct Point {
    int x, y;
};

// Function to fill the polygon using the Scan Line Algorithm
void scanLineFill(vector<Point> polygon) {
    int n = polygon.size();
    int ymin = INT_MAX, ymax = INT_MIN;

    for (int i = 0; i < n; i++) {
        delay(1);
        ymin = min(ymin, polygon[i].y);
        ymax = max(ymax, polygon[i].y);
    }

    for (int y = ymin; y <= ymax; y++) {
        vector<int> intersections;

        for (int i = 0; i < n; i++) {
            delay(1);
            Point p1 = polygon[i];
            Point p2 = polygon[(i + 1) % n];

            if (p1.y == p2.y) continue; // Ignore horizontal edges

            if (y > min(p1.y, p2.y) && y <= max(p1.y, p2.y)) {
                int x = p1.x + (y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y);
                intersections.push_back(x);
            }
        }

        sort(intersections.begin(), intersections.end());

        for (int i = 0; i < intersections.size(); i += 2) {
            delay(1);
            line(intersections[i], y, intersections[i + 1], y);
        }
    }
}

int main() {
    int gd = DETECT, gm;
    initgraph(&gd, &gm, (char*)"");

    vector<Point> polygon = {{200, 100}, {300, 200}, {250, 350}, {150, 350}, {100, 200}}; //A Pentagen

    vector<Point> rect = {{300, 300}, {450, 300}, {450, 450}, {300, 450}}; //A quadrilateral

    // Draw the outline of the Pentagen
    for (int i = 0; i < polygon.size(); i++) {
        Point p1 = polygon[i];
        Point p2 = polygon[(i + 1) % polygon.size()];
        line(p1.x, p1.y, p2.x, p2.y);
    }

    // Draw the outline of the quadrilateral
    for (int i = 0; i < rect.size(); i++) {
        Point p1 = rect[i];
        Point p2 = rect[(i + 1) % rect.size()];
        line(p1.x, p1.y, p2.x, p2.y);
    }
    // Fill the Pentagen using the scan line algorithm
    scanLineFill(polygon);

    // Fill the quadrilateral using the scan line algorithm
    scanLineFill(rect);

    getch();
    closegraph();
    return 0;
}