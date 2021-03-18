%defines
%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

extern int yylex();
extern FILE * yyin;
extern int yydestroy();
int yyerror(const char * e);
%}

%token INT_TYPE FLOAT_TYPE ELEM_TYPE SET_TYPE
%token ID

%%

program: declaration-list { printf("program\n"); } ;

declaration-list: declaration-list declaration 
                | declaration;

declaration: var-declaration { printf("declaration-list-var-declaration\n"); }
           | func-declaration { printf("declaration-list-func-declaration\n"); } ;

type: INT_TYPE { printf("int_type\n"); }
    | FLOAT_TYPE { printf("float_type\n"); }
    | ELEM_TYPE { printf("elem_type\n"); }
    | SET_TYPE { printf("set_type\n"); };

var-declaration: var-declaration-aux | %empty;

var-declaration-aux: type ID ';' { printf("var-declaration-aux\n"); };

params-list: params
           | %empty { printf("params-list-empty\n"); };

params: params ',' param
      | param;

param: type ID;

func-declaration: type ID '(' params-list ')' block-stmt { printf("func-declaration\n"); };

block-stmt: '{' var-declaration '}' { printf("block-stmt\n"); };

%%

int yyerror(const char * e) {
  printf("%s", e);
  return 0;
}

int main() {
  yyparse();
  return 0;
}
