#include <string>
#include <vector>
#include "line.h"

class Function {
public:
    std::string name;
    std::vector<Line *> lines;
    Function(std::string);
};

void readFunctions(void);
void beginFunction(std::string name);
void processFunction(void);
void addLine(std::string text);