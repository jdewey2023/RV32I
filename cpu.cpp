#include <iostream>
#include "io.h"

int main(int argc, char *argv[]){
    if (argc != 2){
        std::cerr << "Usage: cpu <filename>" << std::endl;
        return 1;
    }
    readFunctions();
}