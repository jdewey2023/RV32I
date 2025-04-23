#include <iostream>
#include "line.h"

Line::Line(std::string text){
    this->text = text;
    this->type = INSTRUCTION_T;
}