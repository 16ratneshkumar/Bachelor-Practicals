CC = gcc
LEX = flex
# If bison is unavailable, you can change this to: YACC = yacc -d
YACC = BISON_PKGDATADIR="/c/bison-share" bison -d -y

all: p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12

# Lex only practicals
p1: practical1.l
	$(LEX) practical1.l
	$(CC) lex.yy.c -w -o practical1.exe

p2: practical2.l
	$(LEX) practical2.l
	$(CC) lex.yy.c -w -o practical2.exe

p3: practical3.l
	$(LEX) practical3.l
	$(CC) lex.yy.c -w -o practical3.exe

p4: practical4.l
	$(LEX) practical4.l
	$(CC) lex.yy.c -w -o practical4.exe

p5: practical5.l
	$(LEX) practical5.l
	$(CC) lex.yy.c -w -o practical5.exe

p6: practical6.l
	$(LEX) practical6.l
	$(CC) lex.yy.c -w -o practical6.exe

p7: practical7.l
	$(LEX) practical7.l
	$(CC) lex.yy.c -w -o practical7.exe

p8: practical8.l
	$(LEX) practical8.l
	$(CC) lex.yy.c -w -o practical8.exe

# Lex & Yacc practicals
p9: practical9.l practical9.y
	$(YACC) practical9.y
	$(LEX) practical9.l
	$(CC) lex.yy.c y.tab.c -w -o practical9.exe

p10: practical10.l practical10.y
	$(YACC) practical10.y
	$(LEX) practical10.l
	$(CC) lex.yy.c y.tab.c -w -o practical10.exe

p11: practical11.l practical11.y
	$(YACC) practical11.y
	$(LEX) practical11.l
	$(CC) lex.yy.c y.tab.c -w -o practical11.exe

p12: practical12.l practical12.y
	$(YACC) practical12.y
	$(LEX) practical12.l
	$(CC) lex.yy.c y.tab.c -w -o practical12.exe

# Clean up generated files
clean:
	rm -f lex.yy.c y.tab.c y.tab.h *.exe *.out
