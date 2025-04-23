#pragma once
#include <string>

enum LineType { LABEL_T, DIRECTIVE_T, INSTRUCTION_T };

class Line {
public:
    std::string text;
    enum LineType type;
    Line(std::string);
};
