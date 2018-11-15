all		:	myml

y.tab.h y.tab.c :	myml.y
			bison -y  -d -v  myml.y
lex.yy.c	:	myml.l y.tab.h
			flex myml.l 
myml		:	lex.yy.c y.tab.c Table_des_symboles.c Table_des_chaines.c Attribut.c
			gcc -o myml lex.yy.c y.tab.c Table_des_symboles.c Table_des_chaines.c Attribut.c
clean		:	
			rm -f 	lex.yy.c *.o y.tab.h y.tab.c myml *~ y.output
