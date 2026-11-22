%{
#include <stdio.h>
#include <stdlib.h>
int yylex();
void yyerror(const char *s);
%}

%token VAR NUM

%left '+' '-'
%left '*' '/'

%%
lines:  /* empty */
        | lines expr '\n' { printf("Valid Expression\n"); }
        | lines error '\n' { yyerrok; }
        ;

expr:   VAR
        | NUM
        | expr '+' expr
        | expr '-' expr
        | expr '*' expr
        | expr '/' expr
        | '(' expr ')'
        ;
%%

void yyerror(const char *s) {
    printf("Invalid Expression\n");
}

int main() {
    printf("Enter expression (e.g., a1 + 5): ");
    yyparse();
    return 0;
}