%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "io.h"

struct Operand {
    char *text;
    struct Operand *next;
};

struct OperandList {
    struct Operand *head;
    struct Operand *tail;
};

const char *numberToRegisterName(int num);
char *opsToStr(struct OperandList *list);
struct OperandList *makeOpList(struct Operand *op);
void append_operand(struct OperandList *list, struct Operand *op);
void add_inst(const char *inst);
void add_label(const char *name);
void add_directive(const char *directive);
void yyerror(const char *s);
int yylex(void);

%}

%union {
    long                 imm;
    int                  reg;
    char                *str;
    struct Operand      *operand;
    struct OperandList  *ops;
}

%token <imm>    IMM
%token <reg>    REGISTER
%token <str>    DIRECTIVE IDENT
%token          COLON COMMA LPAREN RPAREN

%type <ops> op_list
%type <operand> operand
%type <str> directive_def instruction label_def

%%

program:
      /* empty */
  | prog_start program
  | function program
    ;

prog_start:
    /* .section .text */
    DIRECTIVE DIRECTIVE
    ;

function:
    header
    lines
        {
            processFunction();
        }
    ;

header:
    DIRECTIVE IDENT
    IDENT COLON { beginFunction($2); free($1); free($2); free($3); }
  | IDENT COLON { beginFunction($1); free($1); }
    ;

lines:
    /* empty line */
  | lines line
    ;

line:
    /* empty */
  | label_def { add_label($1); free($1); }
  | directive_def { add_directive($1); free($1); }
  | instruction {add_inst($1); free($1); }
    ;

label_def:
    IDENT COLON { $$ = strcat($1, ":"); }
    ;

directive_def:
    DIRECTIVE op_list { $$ = strcat($1, opsToStr($2)); }
  | DIRECTIVE { $$ = $1; }
    ;

instruction:
    IDENT op_list { $$ = strcat($1, opsToStr($2)); }
  | IDENT { $$ = $1; }
    ;

op_list:
    operand { $$ = makeOpList($1); }
  | op_list COMMA operand { append_operand($1, $3); $$ = $1; }

operand:
    REGISTER
        {
            $$ = (struct Operand *) malloc(sizeof(*$$));
            $$->text = strdup(numberToRegisterName($1));
            $$->next = NULL;
        }
  | IMM
        {
            // printf("%d\n",$1,yylval.str);
            $$ = (struct Operand *) malloc(sizeof(*$$));
            $$->text = (char *) calloc(500, sizeof(char));
            sprintf($$->text, "%d", $1);
            $$->next = NULL;
        }
  | IMM LPAREN REGISTER RPAREN
        {
            $$ = (struct Operand *) malloc(sizeof(*$$));
            $$->text = (char *) calloc(500, sizeof(char));
            sprintf($$->text, "%d(%s)", $1, numberToRegisterName($3));
            $$->next = NULL;
        }
  | IDENT
        {
            $$ = (struct Operand *) malloc(sizeof(*$$));
            $$->text = strdup($1);
            free($1);
            $$->next = NULL;
        }

%%

const char *numberToRegisterName(int num){
    if (num < 0 || num > 31) return NULL;
    static struct { const char *name; int num; } regs[] = {
        {"zero",0},{"ra",1},{"sp",2},{"gp",3},{"tp",4},
        {"t0",5},{"t1",6},{"t2",7},
        {"s0",8},{"fp",8},{"s1",9},
        {"a0",10},{"a1",11},{"a2",12},{"a3",13},
        {"a4",14},{"a5",15},{"a6",16},{"a7",17},
        {"s2",18},{"s3",19},{"s4",20},{"s5",21},
        {"s6",22},{"s7",23},{"s8",24},{"s9",25},
        {"s10",26},{"s11",27},{"t3",28},{"t4",29},
        {"t5",30},{"t6",31},
        { NULL, 0 }
    };
    return regs[num].name;
}

char *opsToStr(struct OperandList *list){
    if (!list || !list->head) return NULL;
    char *str = (char *) calloc(500, sizeof(char));
    strcpy(str, "\t");
    strcat(str, list->head->text);
    struct Operand *t = NULL;
    for (t = list->head->next; t; t = t->next){
        strcat(str, ",");
        strcat(str, t->text);
    }
    return str;
}

struct OperandList *makeOpList(struct Operand *op){
    struct OperandList *list = (struct OperandList *) malloc(sizeof(*list));
    list->head = list->tail = op;
    op->next = NULL;
    return list;
}

void append_operand(struct OperandList *list, struct Operand *op){
    op->next = NULL;
    list->tail->next = op;
    list->tail = op;
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

void add_inst(const char *inst){
    /* printf("Instruction: %s\n", inst); */
    addLine(inst);
}

void add_label(const char *label) {
    /* printf("Label: %s\n", label); */
    addLine(label);
}

void add_directive(const char *directive){
    /* printf("Directive: %s\n", directive); */
    addLine(directive);
}