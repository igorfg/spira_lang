%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

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
"int"                       { update_position(); printf("<INT_TYPE,%s>\n", yytext); }
"float"                     { update_position(); printf("<FLOAT_TYPE,%s>\n", yytext); }
"elem"                      { update_position(); printf("<ELEM_TYPE,%s>\n", yytext); }
"set"                       { update_position(); printf("<SET_TYPE,%s>\n", yytext); }

  /* Char os string constant with single or double quotes */
\'(\\.|[^'\\])*\'           { update_position(); printf("<STRING_TYPE,%s>\n", yytext); }
\"(\\.|[^"\\])*\"           { update_position(); printf("<STRING_TYPE,%s>\n", yytext); }

  /* Integer Constant */
[\+\-]?{DIGIT}+             { update_position(); printf("<INTCONST,%s>\n", yytext); }
  /* Float Constant */
[\+\-]?{DIGIT}+"."{DIGIT}*  { update_position(); printf("<FLOATCONST,%s>\n", yytext); }

  /* Definition of operators */
"+"                         { update_position(); printf("<ADD_OP,%s>\n", yytext); }
"-"                         { update_position(); printf("<SUB_OP,%s>\n", yytext); }
"*"                         { update_position(); printf("<MULT_OP,%s>\n", yytext); }
"/"                         { update_position(); printf("<DIV_OP,%s>\n", yytext); }

  /* Logical operators */
"!"                         { update_position(); printf("<NOT_OP,%s>\n", yytext); }
"||"                        { update_position(); printf("<OR_OP,%s>\n", yytext); }
"&&"                        { update_position(); printf("<AND_OP,%s>\n", yytext); }

  /* Relational operators */
"<"                         { update_position(); printf("<LESSTHAN_OP,%s>\n", yytext); }
"<="                        { update_position(); printf("<LESSEQUAL_OP,%s>\n", yytext); }
">"                         { update_position(); printf("<GREATERTHAN_OP,%s>\n", yytext); }
">="                        { update_position(); printf("<GREATEREQUAl_OP,%s>\n", yytext); }
"!="                        { update_position(); printf("<NOTEQUAL_OP,%s>\n", yytext); }
"=="                        { update_position(); printf("<COMPARISON_OP,%s>\n", yytext); }

  /* Other symbols */
"{"                         { update_position(); printf("<LBRACE,%s>\n", yytext); }
"}"                         { update_position(); printf("<RBRACE,%s>\n", yytext); }
"("                         { update_position();printf("<LPARENTHESES,%s>\n", yytext); }
")"                         { update_position(); printf("<RPARENTHESES,%s>\n", yytext); }
";"                         { update_position(); printf("<SEMICOLON,%s>\n", yytext); }

"="                         { update_position(); printf("<DEF_EQ,%s>\n", yytext); }
","                         { update_position(); printf("<COMMA,%s>\n", yytext); }

  /* Flow control */
"for"                       { update_position(); printf("<FOR_KW,%s>\n", yytext); }
"if"                        { update_position(); printf("<IF_KW,%s>\n", yytext); }
"else"                      { update_position(); printf("<ELSE_KW,%s>\n", yytext); }
"return"                    { update_position(); printf("<RETURN,%s>\n", yytext); }

  /* Input and Output */
"read"                      { update_position(); printf("<READ_KW,%s>\n", yytext); }
"write"                     { update_position(); printf("<WRITE_KW,%s>\n", yytext); }
"writeln"                   { update_position(); printf("<WRITELN_KW,%s>\n", yytext); }

  /* Whitespaces and newlines */
" "|"\n" {
  update_position();
}
  
  /* ID Definition */
{ID}                        {
                              update_position();
                              printf("<ID,%s>\n", yytext);
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

int main() {
  yylex();
  return 0;
}
