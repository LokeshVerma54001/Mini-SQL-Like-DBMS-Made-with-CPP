%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "globals.h"

extern int yylex();
void yyerror(const char * s);
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

/* ---------------- CREATE TABLE ---------------- */
create_stmt:
    CREATE TABLE IDENT '(' column_list ')' {
        if (table_count >= MAX_TABLES) {
            printf("Error: maximum number of tables reached\n");
        } else {
            // table name
            strncpy(tables[table_count].name, $3, MAX_NAME_LEN - 1);
            tables[table_count].name[MAX_NAME_LEN - 1] = '\0';

            // columns
            tables[table_count].col_count = col_count;
            for (int i = 0; i < col_count; i++) {
                strncpy(tables[table_count].columns[i], col_list[i], MAX_NAME_LEN - 1);
                tables[table_count].columns[i][MAX_NAME_LEN - 1] = '\0';
            }

            tables[table_count].row_count = 0;
            printf("Created table %s with %d columns\n", tables[table_count].name, col_count);
            table_count++;
        }
        // reset temp state
        col_count = 0;
    }
;

/* Build the temporary column list into col_list/col_count */
column_list:
      IDENT {
        col_count = 1;
        strncpy(col_list[0], $1, MAX_NAME_LEN - 1);
        col_list[0][MAX_NAME_LEN - 1] = '\0';
      }
    | column_list ',' IDENT {
        if (col_count < MAX_COLS) {
            strncpy(col_list[col_count], $3, MAX_NAME_LEN - 1);
            col_list[col_count][MAX_NAME_LEN - 1] = '\0';
            col_count++;
        } else {
            printf("Warning: too many columns (max %d); ignoring '%s'\n", MAX_COLS, $3);
        }
      }
;

/* ---------------- INSERT INTO ... VALUES ... ---------------- */
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
                    for (int c = 0; c < value_list_count; c++) {
                        strncpy(tables[i].rows[tables[i].row_count][c],
                                value_list_values[c], MAX_VALUE_LEN - 1);
                        tables[i].rows[tables[i].row_count][c][MAX_VALUE_LEN - 1] = '\0';
                    }
                    tables[i].row_count++;
                    printf("Inserted row into %s\n", $3);
                }
                found = 1;
                break;
            }
        }
        if (!found)
            printf("Error: table %s not found\n", $3);

        // reset temp state
        value_list_count = 0;
    }
;

/* Fill temp value_list_values/value_list_count */
value_list:
      value {
        value_list_count = 1;
        strncpy(value_list_values[0], $1, MAX_VALUE_LEN - 1);
        value_list_values[0][MAX_VALUE_LEN - 1] = '\0';
      }
    | value_list ',' value {
        if (value_list_count < MAX_COLS) {
            strncpy(value_list_values[value_list_count], $3, MAX_VALUE_LEN - 1);
            value_list_values[value_list_count][MAX_VALUE_LEN - 1] = '\0';
            value_list_count++;
        } else {
            printf("Warning: too many values (max %d); ignoring '%s'\n", MAX_COLS, $3);
        }
      }
;

/* A value can be a NUMBER-token-as-string or IDENT-token-as-string */
value:
      NUMBER { $$ = $1; }
    | IDENT  { $$ = $1; }
;

/* ---------------- SELECT * FROM ... ---------------- */
select_stmt:
    SELECT STAR FROM IDENT {
        int found = 0;
        for (int i = 0; i < table_count; i++) {
            if (strcmp(tables[i].name, $4) == 0) {
                printf("Rows in table %s:\n", $4);

                // Column headers
                for (int c = 0; c < tables[i].col_count; c++) {
                    printf("%s\t", tables[i].columns[c]);
                }
                printf("\n");

                // Rows
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
