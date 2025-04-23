%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "rv32i.tab.h"

/* Map register names (case-insensitive) to numbers */
static int registerNameToNumber(const char *name) {
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
    for (int i = 0; regs[i].name; ++i) {
        if (strcasecmp(name, regs[i].name) == 0)
            return regs[i].num;
    }
    return -1;
}
%}

%%

[ \t]+                  ; /* skip whitespace */
"#".*                 ; /* skip comments */
[\r\n]+                ; /* skip newlines */

0[xX][0-9A-Fa-f]+ {
    yylval.str = strdup(yytext);
    yylval.imm = strtol(yytext, NULL, 16);
    return IMM;
}

0[bB][01]+ {
    yylval.str = strdup(yytext);
    yylval.imm = strtol(yytext+2, NULL, 2);
    return IMM;
}

-?[0-9]+ {
    yylval.str = strdup(yytext);
    yylval.imm = strtol(yytext, NULL, 10);
    return IMM;
}

[xX]([0-9]|[12][0-9]|3[01]) {
    yylval.str = strdup(yytext);
    yylval.reg = atoi(yytext+1);
    return REGISTER;
}

(zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]) {
    yylval.str = strdup(yytext);
    yylval.reg = registerNameToNumber(yytext);
    return REGISTER;
}

\.[A-Za-z][A-Za-z0-9_]* {
    yylval.str = strdup(yytext);
    return DIRECTIVE;
}

[A-Za-z_][A-Za-z0-9_]* {
    yylval.str = strdup(yytext);
    return IDENT;
}

":" {
    return COLON;
}

"," {
    return COMMA;
}

"(" {
    return LPAREN;
}

")" {
    return RPAREN;
}

. {
    fprintf(stderr, "Unknown: %s\n", yytext);
    return yytext[0];
}

%%

int yywrap(void) { return 1; }