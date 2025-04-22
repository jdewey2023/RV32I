default: rv32i.l rv32i.y
	bison -d rv32i.y
	flex rv32i.l
	gcc -o assem rv32i.tab.c lex.yy.c -lfl -g

clean:
	rm -rf assem lex.yy.c rv32i.tab.*