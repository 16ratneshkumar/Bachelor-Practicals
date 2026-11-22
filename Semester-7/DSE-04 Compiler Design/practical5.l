%{
#include <stdio.h>
%}

%%
"int"|"float"|"char"|"if"|"else"|"while"|"for"|"return" { printf("Keyword: %s\n", yytext); }
[0-9]+\.[0-9]+          { printf("Float: %s\n", yytext); }
[0-9]+                  { printf("Integer: %s\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*  { printf("Identifier: %s\n", yytext); }
"+"|"-"|"*"|"/"|"="     { printf("Operator: %s\n", yytext); }
"//".*                  { printf("Single-line comment: %s\n", yytext); }
"/*"([^*]|\*+[^*/])*\*+"/" { printf("Multi-line comment\n"); }
[ \t\n]                 { /* Ignore whitespace */ }
.                       { printf("Unknown character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter code: ");
    yylex();
    return 0;
}