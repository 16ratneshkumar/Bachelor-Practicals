%{
#include <stdio.h>
int vowels = 0;
%}

%%
[aeiouAEIOU] { vowels++; }
.            { /* ignore other characters */ }
\n           { /* ignore newlines */ }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter a string: ");
    yylex();
    printf("Number of vowels: %d\n", vowels);
    return 0;
}