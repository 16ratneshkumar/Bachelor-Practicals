#include <graphics.h>
#include <iostream>
#include <cmath>
using namespace std;

struct Point {
    int x, y, w;
};

// Function to apply translation
void translate(Point transformedshape[],int tx, int ty,int n) {
    for (int i = 0; i < n; i++) {
        transformedshape[i].x += tx;
        transformedshape[i].y += ty;
    }
}

// Function to apply scaling
void scale(Point originalshape[], Point transformedshape[], float sx, float sy,int n) {
    for (int i = 0; i < n; i++) {
        transformedshape[i].x = static_cast<int>(originalshape[i].x * sx);
        transformedshape[i].y = static_cast<int>(originalshape[i].y * sy);
    }
    
}

// Function to apply rotation
void rotate(Point originalshape[], Point transformedshape[], float angle,int n) {
    for (int i = 0; i < n; i++) {
    float rad = angle * M_PI / 180.0; // Convert to radians
    int x_new = static_cast<int>(originalshape[i].x * cos(rad) - originalshape[i].y * sin(rad));
    int y_new = static_cast<int>(originalshape[i].x * sin(rad) + originalshape[i].y * cos(rad));
    transformedshape[i].x = x_new;
    transformedshape[i].y = y_new;
    }
}

// Draw Shape
void drawShape(Point shape[], int n) {
    for (int i = 0; i < n; i++) {
        delay(10);
        line(shape[i].x, shape[i].y, shape[(i + 1) % n].x, shape[(i + 1) % n].y);
        delay(10);
    }
}

int main() {
    int gd = DETECT, gm;
    initgraph(&gd, &gm, (char*)"");

    Point originalshape[] = {{50, 50, 1}, {150, 50, 1}, {150, 150, 1}, {50, 150, 1}}; // A quadrilateral
    int n = sizeof(originalshape) / sizeof(originalshape[0]);
    Point transformedshape[4];

    copy(begin(originalshape), end(originalshape), begin(transformedshape));

    // Apply transformations
    int tx = 125, ty = 125; // Translation values
    float sx = 1.5, sy = 1.5; // Scaling factors
    float angle = -25; // Rotation angle in degrees

    // Translate  
    drawShape(originalshape, n);
    translate(transformedshape,tx, ty,n);
    setcolor(YELLOW);
    drawShape(transformedshape, n);
    getch();
    cleardevice();

    // Rotate   
    drawShape(originalshape, n);
    rotate(transformedshape, transformedshape, angle, n);
    setcolor(MAGENTA);
    drawShape(transformedshape, n);
    getch();
    cleardevice();

    // Scale
    drawShape(originalshape, n);
    scale(originalshape, transformedshape, sx, sy,n);
    setcolor(GREEN);
    drawShape(transformedshape, n);
    getch();
    closegraph();
    return 0;
}