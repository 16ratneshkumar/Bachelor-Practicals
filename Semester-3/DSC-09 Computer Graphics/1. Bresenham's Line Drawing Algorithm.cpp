#include <graphics.h>

void bresenhamLine(int x1, int y1, int x2, int y2) {
    int dx = abs(x1 - x2);
    int dy = abs(y1 - y2);
    int p = 2 * dy - dx;
    int twoDy = 2 * dy;
    int twoDyDx = 2 * (dy - dx);
    int x, y,xend;

    if (x1 > x2) {
        x = x2;
        y = y2;
        xend = x1;
    } else {
        x = x1;
        y = y1;
        xend = x2;
    }
    
    putpixel(x, y, WHITE);

    while (x < xend) {
        x++;
        if (p < 0) {
            p += twoDy;
        } else {
            y++;
            p += twoDyDx;
        }
        putpixel(x, y, WHITE);
        delay(2);
    }
}

int main() {
    int gd = DETECT, gm;
    initgraph(&gd, &gm, (char*)"Bresenham's Line Drawing Algorithm");
    
    int x1 = 100, y1 = 100, x2 = 400, y2 = 400;
    bresenhamLine(x1, y1, x2, y2);
    
    getch();
    closegraph();
    return 0;
}