/* Definition section */
%{
    #include "compiler_util.h"
    #include "main.h"

    int yydebug = 1;
%}

/* Variable or self-defined structure */
%union {
    ObjectType var_type;

    bool b_var;
    char c_var;
    int32_t i_var;
    int64_t l_var;
    float f_var;
    double d_var;
    char *s_var;

    Object obj_val;

    // LinkList<Object*>
    LinkedList* array_subscript;
}

/* Token without return */
%token COUT
%token SHR SHL BAN BOR BNT BXO ADD SUB MUL DIV REM NOT GTR LES GEQ LEQ EQL NEQ LAN LOR
%token VAL_ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN REM_ASSIGN BAN_ASSIGN BOR_ASSIGN BXO_ASSIGN SHR_ASSIGN SHL_ASSIGN INC_ASSIGN DEC_ASSIGN
%token IF ELSE FOR WHILE RETURN BREAK CONTINUE

/* Token with return, which need to sepcify type */
%token <var_type> VARIABLE_T
%token <b_var> BOOL_LIT
%token <c_var> CHAR_LIT
%token <i_var> INT_LIT
%token <f_var> FLOAT_LIT
%token <s_var> STR_LIT
%token <s_var> IDENT

/* Nonterminal with return, which need to sepcify type */
%type <obj_val> Expression
%type <array_subscript> ArraySubscriptStmtList

%left ADD SUB
%left MUL DIV REM

%nonassoc THEN
%nonassoc ELSE

/* Yacc will start at this nonterminal */
%start Program

%%
/* Grammar section */

Program
    : { pushScope(); } GlobalStmtList { dumpScope(); }
    | /* Empty file */
;

GlobalStmtList 
    : GlobalStmtList GlobalStmt
    | GlobalStmt
;

GlobalStmt
    : DefineVariableStmt
    | FunctionDefStmt
;

DefineVariableStmt
    : VARIABLE_T IDENT VAL_ASSIGN Expression ';'
;

/* Function */
FunctionDefStmt
    :
;

/* Scope */
ScopeStmt
    : '{' { pushScope(); } StmtList '}' { dumpScope(); }
    | '{' { pushScope(); } '}' { dumpScope(); }
    | BodyStmt
;
ManualScopeStmt
    : '{' StmtList '}'
    | '{' '}'
    | BodyStmt
;
StmtList 
    : StmtList ScopeStmt
    | ScopeStmt
;
BodyStmt
    : ';'
    | WHILE { whileBegin(); } '(' Expression ')' { whileBodyBegin(); } ScopeStmt { whileEnd(); }

    | RETURN Expression ';' { returnObject(&$<obj_val>2); }
    | RETURN ';' { returnObject(NULL); }
    | BREAK ';' { breakLoop(); }
    | CONTINUE ';' { printf("CONTINUE\n"); }
;

%%
/* C code section */