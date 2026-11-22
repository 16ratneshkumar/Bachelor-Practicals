%{
#include <stdio.h>
%}

%%
[a-w]   { printf("%c", yytext[0] + 3); }
[x-z]   { printf("%c", yytext[0] - 23); }
[A-W]   { printf("%c", yytext[0] + 3); }
[X-Z]   { printf("%c", yytext[0] - 23); }
.|\n    { printf("%c", yytext[0]); }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter text to encrypt using Caesar cipher (shift by 3): ");
    yylex();
    return 0;
}