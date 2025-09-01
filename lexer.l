%{
#include "parser.tab.h"
#include <string.h>
#define strdup _strdup  // only if compiling on Windows
%}

%%
CREATE                  { return CREATE; }
TABLE                   { return TABLE; }
INSERT                  { return INSERT; }
SELECT                  { return SELECT; }
FROM                    { return FROM; }
[0-9]+                  { yylval.ival = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return IDENT; }
"*"                     { return STAR; }
";"                     { return SEMICOLON; }
[ \t\n]                 { /* ignore whitespace */ }
.                       { return *yytext; }
%%

int yywrap(void) {
    return 1;
}
