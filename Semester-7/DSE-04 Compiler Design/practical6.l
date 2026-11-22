%{
#include <stdio.h>
int words = 0;
int chars = 0;
int blanks = 0;
int lines = 0;
%}

%%
[a-zA-Z_][a-zA-Z0-9_]* { words++; chars += yyleng; }
[ \t]                  { blanks++; chars++; }
\n                     { lines++; chars++; }
.                      { chars++; }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter C code: ");
    yylex();

    printf("Lines: %d\n", lines);
    printf("Words: %d\n", words);
    printf("Blank spaces: %d\n", blanks);
    printf("Characters: %d\n", chars);

    return 0;
}