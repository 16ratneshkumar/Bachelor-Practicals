%{
#include "y.tab.h"
%}

%%
[a-z][0-9]      { return VAR; }
[0-9]+          { return NUM; }
[+\-*/()]       { return yytext[0]; }
\n              { return '\n'; }
[ \t]           { /* ignore whitespace */ }
.               { return yytext[0]; }
%%

int yywrap() {
    return 1;
}