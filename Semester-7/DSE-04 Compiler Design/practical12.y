%{
#include <stdio.h>
#include <stdlib.h>
int yylex();
void yyerror(const char *s);
%}

%token A B

%%
lines:  /* empty */
        | lines S '\n' { printf("Valid string for a^n b, n>=10\n"); }
        | lines error '\n' { yyerrok; }
        ;

S:      A A A A A A A A A A A_list B
        ;

A_list: /* empty */
        | A A_list
        ;
%%

void yyerror(const char *s) {
    printf("Invalid string\n");
}

int main() {
    printf("Enter string (e.g., aaaaaaaaaab, aaaaaaaaaaab): ");
    yyparse();
    return 0;
}