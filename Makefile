FLAGS = -std=c++17 -g
OBJECTS = rv32i.tab.o lex.yy.o line.o io.o

default: cpu

cpu: $(OBJECTS) cpu.cpp
	g++ $(FLAGS) -o cpu cpu.cpp $(OBJECTS) -lfl

%.o: %.cpp %.h
	g++ $(FLAGS) -c $< -o $@

rv32i.tab.o: rv32i.y
	bison -d rv32i.y
	g++ $(FLAGS) -c rv32i.tab.c -o rv32i.tab.o

lex.yy.o: rv32i.l
	flex rv32i.l
	g++ $(FLAGS) -c lex.yy.c -o lex.yy.o

clean:
	rm -rf assem lex.yy.c rv32i.tab.* rv32i.y.* *.o
