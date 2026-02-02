#include <graphics.h>
#include <conio.h>
#include <iostream>
#include <cmath>

using namespace std;

struct Point3D {
    int x, y, z;
};

Point3D project(Point3D p, int d = 200) {
    // Simple perspective projection
    Point3D projected;
    projected.x = p.x * d / (d + p.z);
    projected.y = p.y * d / (d + p.z);
    projected.z = p.z;
    return projected;
}

void drawCube(Point3D points[]) {
    // Draw lines between points to form a cube
    for (int i = 0; i < 4; i++) {
        Point3D p1 = project(points[i]);
        Point3D p2 = project(points[(i + 1) % 4]);
        Point3D p3 = project(points[i + 4]);
        Point3D p4 = project(points[(i + 1) % 4 + 4]);

        line(p1.x, p1.y, p2.x, p2.y);
        line(p3.x, p3.y, p4.x, p4.y);
        line(p1.x, p1.y, p3.x, p3.y);
    }
}

void translate(Point3D points[], Point3D original[], int tx, int ty, int tz) {
    for (int i = 0; i < 8; i++) {
        points[i].x = original[i].x + tx;
        points[i].y = original[i].y + ty;
        points[i].z = original[i].z + tz;
    }
}

void scale(Point3D points[], Point3D original[], float sx, float sy, float sz) {
    for (int i = 0; i < 8; i++) {
        points[i].x = original[i].x * sx;
        points[i].y = original[i].y * sy;
        points[i].z = original[i].z * sz;
    }
}

void rotateX(Point3D points[], Point3D original[], float angle) {
    float rad = angle * M_PI / 180.0;
    for (int i = 0; i < 8; i++) {
        points[i].x = original[i].x;
        points[i].y = original[i].y * cos(rad) - original[i].z * sin(rad);
        points[i].z = original[i].y * sin(rad) + original[i].z * cos(rad);
    }
}

int main() {
    int gd = DETECT, gm;
    initgraph(&gd, &gm,NULL);

    // Define initial cube points
    Point3D originalCube[8] = {
        {50, 50, 50}, {150, 50, 50}, {150, 150, 50}, {50, 150, 50},
        {50, 50, -50}, {150, 50, -50}, {150, 150, -50}, {50, 150, -50}
    };

    Point3D transformedCube[8];

    // Draw initial cube
    copy(begin(originalCube), end(originalCube), begin(transformedCube));


    // Translate cube
    drawCube(transformedCube);
    setcolor(YELLOW);
    translate(transformedCube, originalCube, 50, 50, 0);
    drawCube(transformedCube);
    getch();
    cleardevice();

    // Scale cube
    drawCube(transformedCube);
    setcolor(GREEN);
    scale(transformedCube, originalCube, 1.5, 1.5, 1.5);
    drawCube(transformedCube);
    getch();
    cleardevice();

    // Rotate cube about X-axis
    drawCube(transformedCube);
    setcolor(CYAN);
    rotateX(transformedCube, originalCube, 45);
    drawCube(transformedCube);
    getch();
    cleardevice();

    
    closegraph();
    return 0;
}