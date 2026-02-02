#include <graphics.h>
#include <vector>
#include <iostream>

struct Point {
    int x, y;
};

// Helper function to check if a point is inside the clipping boundary
bool isInside(Point p, Point clipEdgeStart, Point clipEdgeEnd) {
    return (clipEdgeEnd.x - clipEdgeStart.x) * (p.y - clipEdgeStart.y) - 
           (clipEdgeEnd.y - clipEdgeStart.y) * (p.x - clipEdgeStart.x) >= 0;
}

// Helper function to find the intersection of a polygon edge with the clipping boundary
Point getIntersection(Point s, Point e, Point clipEdgeStart, Point clipEdgeEnd) {
    int x1 = s.x, y1 = s.y;
    int x2 = e.x, y2 = e.y;
    int x3 = clipEdgeStart.x, y3 = clipEdgeStart.y;
    int x4 = clipEdgeEnd.x, y4 = clipEdgeEnd.y;

    int denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    int intersectX = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / denom;
    int intersectY = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / denom;

    return { intersectX, intersectY };
}

// Sutherland-Hodgman Polygon Clipping Algorithm
std::vector<Point> sutherlandHodgmanClip(std::vector<Point>& polygon, std::vector<Point>& clipWindow) {
    std::vector<Point> clippedPolygon = polygon;

    for (size_t i = 0; i < clipWindow.size(); i++) {
        std::vector<Point> newPolygon;
        Point clipEdgeStart = clipWindow[i];
        Point clipEdgeEnd = clipWindow[(i + 1) % clipWindow.size()];

        for (size_t j = 0; j < clippedPolygon.size(); j++) {
            Point current = clippedPolygon[j];
            Point prev = clippedPolygon[(j + clippedPolygon.size() - 1) % clippedPolygon.size()];

            bool currInside = isInside(current, clipEdgeStart, clipEdgeEnd);
            bool prevInside = isInside(prev, clipEdgeStart, clipEdgeEnd);

            if (currInside) {
                if (!prevInside)
                    newPolygon.push_back(getIntersection(prev, current, clipEdgeStart, clipEdgeEnd));
                newPolygon.push_back(current);
            } else if (prevInside) {
                newPolygon.push_back(getIntersection(prev, current, clipEdgeStart, clipEdgeEnd));
            }
        }
        clippedPolygon = newPolygon;
    }
    return clippedPolygon;
}

// Helper function to draw a polygon
void drawPolygon(const std::vector<Point>& polygon, int color) {
    setcolor(color);
    int n = polygon.size();
    for (int i = 0; i < n; i++) {
        delay(50);
        line(polygon[i].x, polygon[i].y, polygon[(i + 1) % n].x, polygon[(i + 1) % n].y);
        delay(50);
    }
}

int main() {
    // Initialize graphics mode
    int gd = DETECT, gm;
    initgraph(&gd, &gm,NULL);

    // Define the polygon to clip
    std::vector<Point> polygon = {{100, 150}, {200, 250}, {300, 200}, {250, 100}, {150, 50}};
    
    // Define the clipping window (rectangular)
    std::vector<Point> clipWindow = {{100, 100}, {300, 100}, {300, 300}, {100, 300}};

    // Clip the polygon
    std::vector<Point> clippedPolygon = sutherlandHodgmanClip(polygon, clipWindow);

    // Draw original polygon in RED
    drawPolygon(polygon, RED);
    delay(900);

    // Draw clipping window in BLUE
    drawPolygon(clipWindow, WHITE);
    delay(900);

    // Draw clipped polygon in GREEN
    drawPolygon(clippedPolygon, GREEN);

    // Pause to view output
    getch();
    closegraph();
    return 0;
}