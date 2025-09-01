%{
#include <stdio.h>
#include <stdlib.h>

//forward declare yylex (from lexer.l)
int yylex();
void yyerror(const char * s);
%}

%union {
    int num;
    char* str;
}

%token <str> IDENT
%token <num> NUMBER
%token CREATE TABLE INSERT SELECT FROM STAR SEMICOLON

%%
command:
      create_stmt SEMICOLON {printf("Parsed CREATE TABLE\n");}
    | insert_stmt SEMICOLON {printf("Parsed INSERT\n");}
    | select_stmt SEMICOLON {printf("Parsed SELECT\n");}
    ;

create_stmt:
    CREATE TABLE IDENT {/* TODO: store table schema */}
    ;

insert_stmt:
    INSERT IDENT {/* TODO: insert into table */}
    ;

select_stmt:
    SELECT STAR FROM IDENT {/* TODO: read from table */}
    ;
%%

void yyerror(const char *s){
    fprintf(stderr, "Parse error: %s\n", s);
}