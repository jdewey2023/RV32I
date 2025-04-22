#include <string>

enum LineType { LABEL, DIRECTIVE, INSTRUCTION }

class Line {
    std::string text;
    enum LineType type;
public:
    Line(std::string);
};
