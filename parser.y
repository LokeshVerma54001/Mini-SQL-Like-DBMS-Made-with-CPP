%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char * s);

#define MAX_COLS 10
#define MAX_ROWS 100
#define MAX_TABLES 10

// Table struct
typedef struct {
    char* name;
    char* col_names[MAX_COLS];
    int col_count;
    char* rows[MAX_ROWS][MAX_COLS]; // store everything as string
    int row_count;
} Table;

Table tables[MAX_TABLES];
int table_count = 0;

// Global column list for CREATE TABLE
char* col_list[MAX_COLS];
int col_count = 0;

// Global value list for INSERT
char* value_list_values[MAX_COLS];
int value_list_count = 0;

%}

%union {
    char* sval;
}

%token <sval> IDENT
%token <sval> NUMBER
%token CREATE TABLE INSERT SELECT FROM STAR SEMICOLON VALUES INTO
%type <sval> column_list value_list value

%%

program:
      program stmt
    | /* empty */
;

stmt:
      create_stmt SEMICOLON
    | insert_stmt SEMICOLON
    | select_stmt SEMICOLON
;

create_stmt:
    CREATE TABLE IDENT '(' column_list ')' {
        if (table_count >= MAX_TABLES) {
            printf("Error: maximum number of tables reached\n");
        } else {
            tables[table_count].name = strdup($3);
            tables[table_count].col_count = col_count;
            for (int i = 0; i < col_count; i++)
                tables[table_count].col_names[i] = strdup(col_list[i]);
            tables[table_count].row_count = 0;
            printf("Created table %s with %d columns\n", $3, col_count);
            table_count++;
        }
    }
;

column_list:
      IDENT {
        col_count = 1;
        col_list[0] = $1;
      }
    | column_list ',' IDENT {
        col_list[col_count++] = $3;
      }
;

insert_stmt:
    INSERT INTO IDENT VALUES value_list {
        int found = 0;
        for (int i = 0; i < table_count; i++) {
            if (strcmp(tables[i].name, $3) == 0) {  // $3 = table name
                if (tables[i].row_count >= MAX_ROWS) {
                    printf("Error: table %s row limit reached\n", $3);
                } else if (value_list_count != tables[i].col_count) {
                    printf("Error: table %s expects %d columns, got %d\n",
                           $3, tables[i].col_count, value_list_count);
                } else {
                    for (int c = 0; c < value_list_count; c++)
                        tables[i].rows[tables[i].row_count][c] = strdup(value_list_values[c]);
                    tables[i].row_count++;
                    printf("Inserted row into %s\n", $3);
                }
                found = 1;
                break;
            }
        }
        if (!found)
            printf("Error: table %s not found\n", $3);
    }
;

value_list:
      value {
        value_list_count = 1;
        value_list_values[0] = $1;
      }
    | value_list ',' value {
        value_list_values[value_list_count++] = $3;
      }
;

value:
      NUMBER { $$ = $1; }
    | IDENT { $$ = $1; }
;

select_stmt:
    SELECT STAR FROM IDENT {
        int found = 0;
        for (int i = 0; i < table_count; i++) {
            if (strcmp(tables[i].name, $4) == 0) {
                printf("Rows in table %s:\n", $4);
                for (int r = 0; r < tables[i].row_count; r++) {
                    for (int c = 0; c < tables[i].col_count; c++)
                        
                        printf("%s\t", tables[i].rows[r][c]);
                    printf("\n");
                }
                found = 1;
                break;
            }
        }
        if (!found)
            printf("Error: table %s not found\n", $4);
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}
