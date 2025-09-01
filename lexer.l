%{
#include "parser.tab.h"
#include <string.h>
#define strdup _strdup  // only if compiling on Windows
%}

%%
"create"                { return CREATE; }
"table"                 { return TABLE; }
"insert"                { return INSERT; }
"into"                  { return INTO; }
"values"                { return VALUES; }
"select"                { return SELECT; }
"from"                  { return FROM; }
"*"                     { return STAR; }
";"                     { return SEMICOLON; }
","                     { return ','; }
"("                     { return '('; }
")"                     { return ')'; }
[0-9]+                  { yylval.sval = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return IDENT; }
[ \t\n]+                ;   // skip whitespace
.                       { return yytext[0]; }
%%


int yywrap(void) {
    return 1;
}
