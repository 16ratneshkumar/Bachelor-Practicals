%{
#include <stdio.h>
int lines = 0;
int chars = 0;
%}

%%
\n      { lines++; chars++; }
.       { chars++; }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter text: ");
    yylex();
    printf("Lines: %d\n", lines);
    printf("Characters: %d\n", chars);
    return 0;
}