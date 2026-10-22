/*simplest version of calculator: from O'Reilly Media, Inc. 2021*/
%{  // Section 1a: C declarations
  #include<stdio.h>
  #include<math.h>
  int yylex();
  void yyerror(char *s);
%}

// Section 1b: YACC/Bison declarations
/* this makes every semantic value a double, so one type holds integers and decimals */
%define api.value.type {double}

/*declare tokens*/
%token NUMBER
%token ADD SUB MUL DIV
%token POW
%token EOL QUIT

%%  // Section 2: Grammar rules
calclist: /*nothing*/		//matches at beginning of input
  | calclist exp EOL 		{printf("=%.15g\n", $2); } //EOL is end of an expression
  | calclist QUIT 			{printf("Exitting..."); return 0;}
  ;

exp: factor 				//default $$ = $1
  | exp ADD factor 			{$$ = $1 + $3;}
  | exp SUB factor 			{$$ = $1 - $3;}
  ;

factor: power				//default $$ = $1
  | factor MUL power 		{$$ = $1 * $3;}
  | factor DIV power 		{$$ = $1 / $3;}
  ;

/* keeping power on the right makes chained exponents right-associative */
power: term                   //default $$ = $1
  | term POW power            {
      double whole_part;
      if (modf($3, &whole_part) != 0.0) {
        yyerror("exponent must be an integer!");
        YYERROR;
      }
      $$ = pow($1, $3);
    }
  ;

term: NUMBER                  //default $$ = $1
  ;
%%

// Section 3: Additional C code
void yyerror(char *s){
  fprintf(stderr, "error: %s\n", s);
}

int main(int argc, char **argv){
  yyparse();
}
