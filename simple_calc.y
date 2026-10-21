/*simplest version of calculator: from O'Reilly Media, Inc. 2021*/
%{  // Section 1a: C declarations
  #include<stdio.h>
  int yylex();
  void yyerror(char *s);
%}

// Section 1b: YACC/Bison declarations
/*declare tokens*/
%token NUMBER
%token ADD SUB MUL DIV
%token EOL QUIT

%%  // Section 2: Grammar rules
calclist: /*nothing*/		//matches at beginning of input
  | calclist exp EOL 		{printf("=%d\n", $2); } //EOL is end of an expression
  | calclist QUIT 			{printf("Exitting..."); return 0;}
  ;

exp: factor 				//default $$ = $1
  | exp ADD factor 			{$$ = $1 + $3;}
  | exp SUB factor 			{$$ = $1 - $3;}
  ;

factor: term				//default $$ = $1
  | factor MUL term 		{$$ = $1 * $3;}
  | factor DIV term 		{$$ = $1 / $3;}
  ;

term: NUMBER 				//default $$ = $1
  ;
%%

// Section 3: Additional C code
void yyerror(char *s){
  fprintf(stderr, "error: %s\n", s);
}

int main(int argc, char **argv){
  yyparse();
}
