/*simplest version of calculator: from O'Reilly Media, Inc. 2021*/
%{  // Section 1a: C declarations
  #include<stdio.h>
  #include<math.h>
  int yylex();
  void yyerror(char *s);

  /* one slot per ASCII character, so a variable's letter is its own index */
  double vars[128];
  int is_set[128];
%}

// Section 1b: YACC/Bison declarations
/* a semantic value is either a number (integers and decimals) or a variable's letter */
%union {
  double number;
  int letter;
}

/* look at the next token before reducing, so a line with bad syntax cannot assign a variable */
%define lr.default-reduction consistent

/*declare tokens*/
%token <number> NUMBER
%token <letter> VAR
%token ADD SUB MUL DIV
%token POW
%token LPAREN RPAREN
%token ASSIGN
%token EOL QUIT
%token INVALID				/* no rule uses this, so it always causes a syntax error */

%type <number> assign exp factor unary power term

%%  // Section 2: Grammar rules
calclist: /*nothing*/		//matches at beginning of input
  | calclist EOL 			//blank line, nothing to do
  | calclist assign EOL 	{printf("=%.15g\n", $2); } //EOL is end of an expression
  | calclist error EOL 		{yyerrok;} //skip the bad line and continue with the next one
  | calclist QUIT 			{printf("Exitting..."); return 0;}
  ;

/* keeping assign on the right makes chained assignments right-associative */
assign: exp 				//default $$ = $1
  | VAR ASSIGN assign 		{vars[$1] = $3; is_set[$1] = 1; $$ = $3;}
  ;

exp: factor 				//default $$ = $1
  | exp ADD factor 			{$$ = $1 + $3;}
  | exp SUB factor 			{$$ = $1 - $3;}
  ;

factor: unary				//default $$ = $1
  | factor MUL unary 		{$$ = $1 * $3;}
  | factor DIV unary 		{
      if ($3 == 0.0) {
        yyerror("division by zero!");
        YYERROR;
      }
      $$ = $1 / $3;
    }
  ;

/* sits above power so that -2^2 is -(2^2), as in PEMDAS */
unary: power				//default $$ = $1
  | SUB unary 				{$$ = -$2;}
  ;

/* keeping the exponent on the right makes chained exponents right-associative */
power: term                   //default $$ = $1
  | term POW unary            {
      double whole_part;
      if (modf($3, &whole_part) != 0.0) {
        yyerror("exponent must be an integer!");
        YYERROR;
      }
      if ($1 == 0.0 && $3 < 0.0) {	/* 0^-1 is the same as 1/0 */
        yyerror("division by zero!");
        YYERROR;
      }
      $$ = pow($1, $3);
    }
  ;

term: NUMBER                  //default $$ = $1
  | VAR                       {
      if (!is_set[$1]) {
        char message[40];
        sprintf(message, "variable %c is not defined!", $1);
        yyerror(message);
        YYERROR;
      }
      $$ = vars[$1];
    }
  | LPAREN exp RPAREN         {$$ = $2;}
  ;
%%

// Section 3: Additional C code
void yyerror(char *s){
  fflush(stdout);	/* keep results and errors in order when both go to the same place */
  fprintf(stderr, "error: %s\n", s);
  fflush(stderr);
}

int main(int argc, char **argv){
  yyparse();
}
