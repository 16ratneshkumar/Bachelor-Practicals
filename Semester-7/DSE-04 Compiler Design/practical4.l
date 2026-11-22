%{
#include <stdio.h>
#include <string.h>

int max_len = 0;
char longest_word[100];
%}

%%
[a-zA-Z]+ { 
    if (yyleng > max_len) {
        max_len = yyleng;
        strcpy(longest_word, yytext);
    }
}
.|\n { /* ignore other characters */ }
%%

int yywrap() {
    return 1;
}

int main() {
    printf("Enter text: ");
    yylex();

    if (max_len > 0) {
        printf("Longest word is '%s' with length %d\n", longest_word, max_len);
    } else {
        printf("No words found.\n");
    }
    return 0;
}