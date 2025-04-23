#include <iostream>
#include "rv32i.tab.h"
#include "line.h"
#include "io.h"

Function *function;

Function::Function(std::string name){
    this->name = name;
}

void readFunctions(void){
    yyparse();
}

void beginFunction(std::string name){
    function = new Function(name);
}

void processFunction(void){
    for (auto line : function->lines){
        std::cout << line->text << std::endl;
    }
    function->lines.clear();
    delete function;
}

void addLine(std::string text){
    Line *l = new Line(text);
    function->lines.push_back(l);
}