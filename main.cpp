#include <cstdio>
#include <cstdlib>
#include "globals.h"
#include "file_IO.h"

extern int yyparse();

int main() {
    printf("Mini-SQL starting...\n");
    load_all_tables();
    yyparse();
    save_tables();
    return 0;
}
