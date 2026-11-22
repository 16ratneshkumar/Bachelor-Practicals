%{
#include <stdio.h>
#include <stdlib.h>
int yylex();
void yyerror(const char *s);
%}

%token A B

%%
lines:  /* empty */
        | lines S '\n' { printf("Valid string for a^n b^n\n"); }
        | lines error '\n' { yyerrok; }
        ;

S:      A B
        | A S B
        ;
%%

void yyerror(const char *s) {
    printf("Invalid string\n");
}

int main() {
    printf("Enter string (e.g., ab, aabb, aaabbb): ");
    yyparse();
    return 0;
}