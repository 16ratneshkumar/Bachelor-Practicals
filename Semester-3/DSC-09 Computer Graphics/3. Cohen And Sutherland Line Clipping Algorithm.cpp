#include <iostream>
#include <graphics.h>

using namespace std;

// Define region codes
const int INSIDE = 0; // 0000
const int LEFT = 1;   // 0001
const int RIGHT = 2;  // 0010
const int BOTTOM = 4; // 0100
const int TOP = 8;    // 1000

// Function to compute the region code for a point (x, y)
int computeRegionCode(double x, double y, double x_min, double x_max, double y_min, double y_max) {
    int code = INSIDE;

    if (x < x_min) // to the left of the rectangle
        code |= LEFT;
    else if (x > x_max) // to the right of the rectangle
        code |= RIGHT;
    if (y < y_min) // below the rectangle
        code |= BOTTOM;
    else if (y > y_max) // above the rectangle
        code |= TOP;

    return code;
}

// Cohen-Sutherland Line Clipping algorithm
void cohenSutherlandClip(double x0, double y0, double x1, double y1, double x_min, double x_max, double y_min, double y_max) {
    // Initialize graphical mode
    int gd = DETECT, gm;
    initgraph(&gd, &gm, NULL);

    // Draw clipping rectangle
    rectangle(x_min, y_min, x_max, y_max);

    // Draw original line
    setcolor(RED);
    line(x0, y0, x1, y1);

    // Compute region codes for both points
    int code0 = computeRegionCode(x0, y0, x_min, x_max, y_min, y_max);
    int code1 = computeRegionCode(x1, y1, x_min, x_max, y_min, y_max);

    bool accept = false;

    while (true) {
        if ((code0 == 0) && (code1 == 0)) {
            // Both endpoints lie inside the rectangle
            accept = true;
            break;
        } else if (code0 & code1) {
            // Both endpoints are outside the rectangle in the same region
            break;
        } else {
            // At least one endpoint is outside the rectangle
            double x, y;

            // Pick the outside point
            int outcode = (code0 != 0) ? code0 : code1;

            // Find intersection point
            if (outcode & TOP) { // point is above the clip rectangle
                x = x0 + (x1 - x0) * (y_max - y0) / (y1 - y0);
                y = y_max;
            } else if (outcode & BOTTOM) { // point is below the rectangle
                x = x0 + (x1 - x0) * (y_min - y0) / (y1 - y0);
                y = y_min;
            } else if (outcode & RIGHT) { // point is to the right of the rectangle
                y = y0 + (y1 - y0) * (x_max - x0) / (x1 - x0);
                x = x_max;
            } else if (outcode & LEFT) { // point is to the left of the rectangle
                y = y0 + (y1 - y0) * (x_min - x0) / (x1 - x0);
                x = x_min;
            }

            // Now move outside point to intersection point to clip
            if (outcode == code0) {
                x0 = x;
                y0 = y;
                code0 = computeRegionCode(x0, y0, x_min, x_max, y_min, y_max);
            } else {
                x1 = x;
                y1 = y;
                code1 = computeRegionCode(x1, y1, x_min, x_max, y_min, y_max);
            }
        }
    }

    if (accept) {
        // The line is within the rectangle, draw the clipped line in green
        setcolor(GREEN);
        line(x0, y0, x1, y1);
        cout << "Line accepted from (" << x0 << ", " << y0 << ") to (" << x1 << ", " << y1 << ")" << endl;
    } else {
        // The line is outside the rectangle
        cout << "Line rejected" << endl;
    }

    // Pause to display the result
    getch();
    closegraph();
}

int main() {
    double x_min = 150.0, y_min = 150.0, x_max = 350.0, y_max = 350.0;
    double x0 = 100.0, y0 = 200.0, x1 = 400.0, y1 = 300.0;

    cohenSutherlandClip(x0, y0, x1, y1, x_min, x_max, y_min, y_max);

    return 0;
}