#include <graphics.h>

void circleplotPoints(int xc,int yc,int x,int y){
    putpixel(xc + x, yc + y, WHITE);
    putpixel(xc - x, yc + y, WHITE);
    putpixel(xc + x, yc - y, WHITE);
    putpixel(xc - x, yc - y, WHITE);
    putpixel(xc + y, yc + x, WHITE);
    putpixel(xc - y, yc + x, WHITE);
    putpixel(xc + y, yc - x, WHITE);
    putpixel(xc - y, yc - x, WHITE);
}

void midpointCircle(int xc, int yc, int r) {
    int x = 0, y = r;
    int p = 1 - r;

    circleplotPoints(xc,yc,x,y);
    while (x <= y) {
        
        x++;
        if (p < 0) {
            p += 2 * x + 1;
        } else {
            y--;
            p += 2 * (x - y) + 1;
        }
        circleplotPoints(xc,yc,x,y);
        delay(4);
    }
}

int main() {
    int gd = DETECT, gm;
    initgraph(&gd, &gm, (char*)"");
    
    int xc = 300, yc = 250, radius = 150;
    midpointCircle(xc, yc, radius);
    
    getch();
    closegraph();
    return 0;
}