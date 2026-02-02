#include <graphics.h>
#include <cmath>

void linedda(int x1,int y1,int x2,int y2){
    int dx = x2 - x1;
    int dy= y2 - y1;
    int steps;
    int k;
    float xIncr;
    float yIncr;
    float x=x1;
    float y=y1;
    if (abs(dx)>abs(dy)) steps =abs(dx);
    else steps =abs(dy);

    xIncr = dx/(float) steps;
    yIncr = dy/(float) steps;

    putpixel(round(x),round(y),WHITE);
    for(k=0;k<steps;k++){
        x+=xIncr;
        y+=yIncr;
        putpixel(round(x),round(y),WHITE);
        delay(2);
    }
}

int main() {
    int gd = DETECT, gm;
    initgraph(&gd, &gm, (char*)"");
    
    int x1 = 100, y1 = 100, x2 = 400, y2 = 400;
    linedda(x1,y1, x2, y2);
    
    getch();
    closegraph();
    return 0;
}