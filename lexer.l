%{
#include "parser.tab.h"
#include <string.h>
#define strdup _strdup
%}

%%
CREATE {return CREATE;}
TABLE  {return TABLE;}
INSERT {return INSERT;}
SELECT {return SELECT;}
FROM   {return FROM;}
[0-9]+ {yylval = atoi(yytext); return NUMBER;}
[a-zA-Z_][a-zA-Z0-9_]* {yylval = _strdup(yytext); return IDENT;}
"*"    {return STAR;}
";"    {return SEMICOLON;}
[ \t\n] // ignore spaces
.       {return *yytext;} 
%%

