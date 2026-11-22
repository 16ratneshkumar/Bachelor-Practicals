%{
#include <stdio.h>
int op = 0;
int id = 0;
int valid = 1;
%}

%%
[a-zA-Z0-9]+    { id++; printf("Operand\n"); }
[+\-*/]         { op++; printf("Operator\n"); }
[ \t\n]         { /* ignore */ }
.               { valid = 0; }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter an arithmetic expression: ");
    yylex();
    
    if (valid && id == op + 1 && id >= 1) {
        printf("Valid Arithmetic Expression\n");
    } else {
        printf("Invalid Arithmetic Expression\n");
    }
    return 0;
}