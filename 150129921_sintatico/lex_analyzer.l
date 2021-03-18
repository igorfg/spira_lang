%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "syn_analyzer.tab.h"

int current_line = 1;
int current_col = 1;
int previous_col;

static void update_position(void);
%}

/* Options to generate the output file without the need of extra declarations */
%option noinput nounput
%option never-interactive
%option noyywrap

/* Directives for comment block or comment lines */
%x COMMENTLINE
%x COMMENTBLOCK

/* REGEX declarations to increase code readbility */
DIGIT [0-9]
LETTER [a-zA-Z]
ID ({LETTER}|"_")+({LETTER}|{DIGIT}|"_")*


%%
  /* Multiline Comments */
"/*" {
  update_position();
  BEGIN(COMMENTBLOCK);
}
<COMMENTBLOCK>"*/" {
  update_position();
  BEGIN(INITIAL);
}
<COMMENTBLOCK>\n {
  update_position();
}
<COMMENTBLOCK>. {
  update_position();
}

  /* Single line comments */
"//" {
  update_position();
  BEGIN(COMMENTLINE);
}
<COMMENTLINE>\n {
  update_position();
  BEGIN(INITIAL);
}
<COMMENTLINE>. {
  update_position();
}

  /* Data types are int, float elem and set */
"int"                       { update_position(); return INT_TYPE; }
"float"                     { update_position(); return FLOAT_TYPE; }
"elem"                      { update_position(); return ELEM_TYPE; }
"set"                       { update_position(); return SET_TYPE; }

  /* Char os string constant with single or double quotes */
\'(\\.|[^'\\])*\'           { update_position(); /*return STRING_TYPE;*/ }
\"(\\.|[^"\\])*\"           { update_position(); /*return STRING_TYPE;*/ }

  /* Integer Constant */
[\+\-]?{DIGIT}+             { update_position(); /*return INTCONST;*/ }
  /* Float Constant */
[\+\-]?{DIGIT}+"."{DIGIT}*  { update_position(); /*return FLOATCONST;*/ }

  /* Definition of operators */
"+"                         { update_position(); /*return ADD_OP;*/ }
"-"                         { update_position(); /*return SUB_OP;*/ }
"*"                         { update_position(); /*return MULT_OP;*/ }
"/"                         { update_position(); /*return DIV_OP;*/ }

  /* Logical operators */
"!"                         { update_position(); /*return NOT_OP;*/ }
"||"                        { update_position(); /*return OR_OP;*/ }
"&&"                        { update_position(); /*return AND_OP;*/ }

  /* Relational operators */
"<"                         { update_position(); /*return LESSTHAN_OP;*/ }
"<="                        { update_position(); /*return LESSEQUAL_OP;*/ }
">"                         { update_position(); /*return GREATERTHAN_OP;*/ }
">="                        { update_position(); /*return GREATEREQUAl_OP;*/ }
"!="                        { update_position(); /*return NOTEQUAL_OP;*/ }
"=="                        { update_position(); /*return COMPARISON_OP;*/ }

  /* Other symbols */
"{"                         { update_position(); return '{'; }
"}"                         { update_position(); return '}'; }
"("                         { update_position(); return '('; }
")"                         { update_position(); return ')'; }
";"                         { update_position(); return ';'; }

"="                         { update_position(); /*return DEF_EQ;*/ }
","                         { update_position(); return ','; }

  /* Flow control */
"for"                       { update_position(); /*return FOR_KW;*/ }
"if"                        { update_position(); /*return IF_KW;*/ }
"else"                      { update_position(); /*return ELSE_KW;*/ }
"return"                    { update_position(); /*return RETURN;*/ }

  /* Input and Output */
"read"                      { update_position(); /*return READ_KW;*/ }
"write"                     { update_position(); /*return WRITE_KW;*/ }
"writeln"                   { update_position(); /*return WRITELN_KW;*/ }

  /* Whitespaces and newlines */
" "|"\n" {
  update_position();
}
  
  /* ID Definition */
{ID}                        {
                              update_position();
                              return ID;
                            }

  /* Error handling */
.                           {
                              update_position();
                              printf("Token not recognized: %s. Line: %d, Column: %d\n", yytext, current_line, current_col);
                            }

%%

/* Updates line in case of newline and updates column otherwise */
static void update_position(void) {
  previous_col = current_col;
  for (int nsymbol = 0; nsymbol < yyleng; ++nsymbol) {
    if (yytext[nsymbol] == '\n') {
      current_col = 1;
      previous_col = 1;
      current_line++;
    } else {
      current_col++;
    }
  }
}