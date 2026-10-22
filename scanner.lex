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
{NUM}		{yylval = atof(yytext); return NUMBER;}   /* converts matched text to double and pass it to the parser */
\n			{return EOL;}
[[:space:]]	{/*ignore white space*/}
"exit"		{return QUIT;}
.			{printf("\nUnrecognized string %c\n", *yytext);}
%%
