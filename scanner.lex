%{
  #include "simple_calc.tab.h"
  #include <stdlib.h>
%}

/* accept integers and decimals, including .36 and 17. */
NUM	([0-9]+(\.[0-9]*)?|\.[0-9]+)

%%
"+"			{return ADD;}
"-"			{return SUB;}
"/"			{return DIV;}
"*"			{return MUL;}
"^"			{return POW;}
"("			{return LPAREN;}
")"			{return RPAREN;}
"="			{return ASSIGN;}
{NUM}		{yylval.number = atof(yytext); return NUMBER;}   /* converts matched text to double and pass it to the parser */
\n			{return EOL;}
[[:space:]]	{/*ignore white space*/}
"exit"		{return QUIT;}   /* longer than one letter, so flex prefers it over the variable rule */
[a-zA-Z]	{yylval.letter = yytext[0]; return VAR;}   /* one-letter variable name */
.			{printf("\nUnrecognized string %c\n", *yytext); return INVALID;}
<<EOF>>		{   /* the last line may have no \n, so end it once before stopping */
			  static int sent_last_eol = 0;
			  if (sent_last_eol) return 0;
			  sent_last_eol = 1;
			  return EOL;
			}
%%
