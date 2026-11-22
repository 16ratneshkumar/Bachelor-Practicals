%{
#include <stdio.h>
#include <string.h>
%}

%%
"abcd" {
    int len = yyleng;
    for (int i = 0; i < len; i++) {
        for (int j = 0; j < len - i; j++) {
            printf("%c", yytext[j]);
        }
        printf("\n");
    }
}
.|\n { /* ignore other inputs */ }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter string 'abcd': ");
    yylex();
    return 0;
}