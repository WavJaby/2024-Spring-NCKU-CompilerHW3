CFLAGS := -Wall -O0 -ggdb
YFLAG := -d -v
MAIN_SRC := ./main.c
LEX_SRC := ./compiler.l
YAC_SRC := ./compiler.y
BUILD := ./build#							Do not touch
COMPILER := compiler#						Do not touch
EXEC := Main#								Do not touch

BUILD_OUT := ${BUILD}/out# 					Do not touch
COMPILER_OUT := ${BUILD_OUT}/${COMPILER}# 	Do not touch
LEX_OUT := ${BUILD}/lex.yy.c
YAC_OUT := ${BUILD}/y.tab.c
MAIN_OUT := ${BUILD}/main.o

IN := ./input/subtask01-helloworld/testcase01.cpp
ASM_OUT := ${BUILD}/Main.j# 				Do not touch
PGM_OUT := ${BUILD_OUT}/${EXEC}.class# 		Do not touch

all: build compile_asm run

build: build_compiler # Do not edit

.PHONY: main.c

create_build_folder:
	mkdir -p ${BUILD}
	mkdir -p ${BUILD_OUT}

lex.yy.c:
	$(info ---------- Compile Lex ----------)
	lex -o ${LEX_OUT} ${LEX_SRC}

y.tab.c:
	$(info ---------- Compile Yacc ----------)
	yacc ${YFLAG} -o ${YAC_OUT} ${YAC_SRC}

main.c:
	$(info ---------- Compile ${MAIN_SRC} ----------)
	gcc -g -c ${MAIN_SRC} -o ${MAIN_OUT}

build_compiler: create_build_folder lex.yy.c y.tab.c main.c
	$(info ---------- Create compiler ----------)
	gcc ${CFLAGS} -o ${COMPILER_OUT} -iquote ./ -iquote ../ ${LEX_OUT} ${YAC_OUT} ${MAIN_OUT}

compile_cmm:
	$(info ---------- Compile c-- to Java ASM ----------)
	@rm -f ${ASM_OUT}
	${COMPILER_OUT} ${IN} ${ASM_OUT}

compile_asm: compile_cmm # Do not edit
	$(info ---------- Compile Java ASM to Java bytecode ----------)
	@test -f "${ASM_OUT}" || (echo "\"${ASM_OUT}\" does not exist."; exit 1)
	@rm -f ${PGM_OUT}
	@java -jar jasmin.jar -g ${ASM_OUT} -d ${BUILD_OUT}

run_nomsg: # Do not edit
	@cd ${BUILD_OUT} && java ${EXEC}

run:
	$(info ---------- Run program ----------)
	@test -f "${PGM_OUT}" || (echo "\"${PGM_OUT}\" does not exist."; exit 1)

	@cd ${BUILD_OUT} && java ${EXEC}

clean:
	rm -rf ${BUILD}
