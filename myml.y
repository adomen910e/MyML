
%{


#include "Attribut.h"  // header included in y.tab.h
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

  
extern int yylex();
extern int yyparse();

void yyerror (char* s) {
   printf("\n%s\n",s);
 }

%}

%union {
        long value;
        char id;
}

%{
    static int tab[26][2];
    int type;
%}

%token<value>   NUM FLOAT STRING ID

%type<value> atom_exp
%type<value> aff_id aff exp arith_exp let_exp control_exp comp bool


%token PV LPAR RPAR LBR RBR LET IN VIR

%token IF THEN ELSE

%token ISLT ISGT ISLEQ ISGEQ ISEQ
%left ISEQ
%left ISLT ISGT ISLEQ ISGEQ


%token AND OR NOT BOOL
%left OR
%left AND



%token PLUS MOINS MULT DIV EQ
%left PLUS
%left MULT
%left CONCAT
%nonassoc UNA    /* pseudo token pour assurer une priorite locale */


%start prog 
 


%%

prog : inst PV
| prog inst PV
;

inst : aff
| exp
;


aff : aff_id
| aff_fun
;

aff_id : ID EQ exp                                                              {
                                                                            if(type == 1){
                                                                                if(tab[$1 - 'a'][0] == -1){
                                                                                    tab[$1 - 'a'][0] = $3;
                                                                                    printf("%c de type <int> vaut %d\n", $1, $3);
    }
                                                                                 else{
                                                                                     tab[$1 - 'a'][1] = $3;
                                                                                     printf("let %c de type <int> vaut %d\n", $1, $3);
                                                                                 }
                                                                            }
};
;

aff_fun : fun_head EQ exp
;

fun_head : ID id_list 
;

id_list : ID
| id_list ID
;


exp : arith_exp
| atom_exp
| control_exp
| let_exp
| LPAR funcall_exp RPAR
;

arith_exp : MOINS exp %prec UNA             
| exp PLUS exp                                                                  {int var1 = $1;
                                                                                int var2 = $3;
                                                                                bool b1 = (var1==(-1));
                                                                                bool b2 = (var2==(-1));

                                                                                if(b1){
                                                                                    printf("[ERROR]  variable non declarée\n");
                                                                                }else if(b2){
                                                                                    printf("[ERROR]  variable non declarée\n");
                                                                                }else{
                                                                                    $$ = var1 + var2;
                                                                                    printf("<exp> de type <> vaut %d\n",$$);
                                                                                };
};
| exp MULT exp
| exp CONCAT exp
;

atom_exp : NUM                                                                  {type = 1; $$ = $1;}
| FLOAT                                                                         {type = 2; $$ = $1;}
| STRING                                                                        
| ID                                                                            {if(tab[$1 - 'a'][1] != -1)
                                                                                  $$ = tab[$1 - 'a'][1];
                                                                                else
                                                                                  $$ = tab[$1 - 'a'][0];}
| list_exp
| LPAR exp RPAR                                                                 {$$ = $2;}
;

control_exp : IF bool THEN atom_exp ELSE atom_exp                              {if($2){
    $$ = $4;
}else{
    $$ = $6;
}

}
;

let_exp : LET aff IN atom_exp                                                  {$$ = $4 ;
                                                                                tab[$2 - 'a'][1] = -1;}
;

funcall_exp : ID atom_list
;

atom_list : atom_exp
| atom_list atom_exp
;


list_exp : LBR exp_list RBR
;

exp_list : exp
| exp_list VIR exp
;

bool : BOOL
| bool OR bool
| bool AND bool
| NOT bool %prec UNA 
| exp comp exp          {if ($2 == 1){bool result = ($1 == $3); $$ = result;};}
| LPAR bool RPAR        {$$ = $2;}
;


comp :  ISLT
| ISGT
| ISLEQ
| ISGEQ
| ISEQ          {$$ = 1;}
;

%% 
int main () {
    for(int i=0; i<26; i++){
        tab[i][1] = -1;
        tab[i][0] = -1;
    }

    return yyparse ();
} 

