#include <cstdio>
#include <cstdlib>

extern int yyparse();

int main() {
    printf("Mini-SQL starting...\n");
    yyparse();
    return 0;
}
