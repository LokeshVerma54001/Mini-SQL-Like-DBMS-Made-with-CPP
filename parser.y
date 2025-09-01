%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// forward declare yylex (from lexer.l)
int yylex();
void yyerror(const char * s);

/* Define Table Struct here */
typedef struct {
    char* name;
    int rows[100];
    int row_count;
} Table;

Table tables[10];
int table_count = 0;

%}

/* Define YYSTYPE */
%union {
    int ival;
    char* sval;
};

/* Declare token types */
%token <ival> NUMBER
%token <sval> IDENT
%token CREATE TABLE INSERT SELECT FROM STAR SEMICOLON

%%

commands:
    /* empty */
  | commands command
  ;

command:
      create_stmt SEMICOLON { printf("Parsed CREATE TABLE\n"); }
    | insert_stmt SEMICOLON { printf("Parsed INSERT\n"); }
    | select_stmt SEMICOLON { printf("Parsed SELECT\n"); }
    ;

create_stmt:
    CREATE TABLE IDENT { 
        if (table_count >= 10) {
            printf("Error: maximum number of tables reached\n");
        } else {
            tables[table_count].name = strdup($3);   // copy identifier safely
            tables[table_count].row_count = 0;
            printf("Table created: %s\n", $3);
            table_count++;
        }
    }
    ;

insert_stmt:
    INSERT IDENT NUMBER { 
        int found = 0;
        for (int i = 0; i < table_count; i++) {
            if (strcmp(tables[i].name, $2) == 0) {
                if (tables[i].row_count >= 100) {
                    printf("Error: table %s row limit reached\n", $2);
                } else {
                    tables[i].rows[tables[i].row_count++] = $3;
                    printf("Inserted %d into %s\n", $3, $2);
                }
                found = 1;
                break;
            }
        }
        if (!found) {
            printf("Error: table %s not found\n", $2);
        }
    }
    ;

select_stmt:
    SELECT STAR FROM IDENT { 
        int found = 0;
        for (int i = 0; i < table_count; i++) {
            if (strcmp(tables[i].name, $4) == 0) {
                printf("Table %s:\n", $4);
                for (int j = 0; j < tables[i].row_count; j++) {
                    printf("%d\n", tables[i].rows[j]);
                }
                found = 1;
                break;
            }
        }
        if (!found) {
            printf("Error: table %s not found\n", $4);
        }
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}
