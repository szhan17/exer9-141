%{
  #include "simple_calc.tab.h"
%}

NUM	[0-9]+

%%
"+"			{return ADD;}
"-"			{return SUB;}
"/"			{return DIV;}
"*"			{return MUL;}
{NUM}		{yylval = atoi(yytext); return NUMBER;}
\n			{return EOL;}
[[:space:]]	{/*ignore white space*/}
"exit"		{return QUIT;}
.			{printf("\nUnrecognized string %c\n", *yytext);}
%%

