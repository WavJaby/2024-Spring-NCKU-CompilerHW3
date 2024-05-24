#ifndef COMPILER_UTIL_H
#define COMPILER_UTIL_H

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern int yylineno;
extern int yycolumn;
extern int yyoffset;
extern int yyleng;
extern char* yyInputFileName;
extern bool compileError;
extern FILE* yyin;

#define ERROR_PREFIX "%s:%d:%d: error: "
#define ERROR_TEXT_BUFFER_LEN 128
#define ERROR_TOKEN_BUFFER_LEN 64
#define COLOR_RED "\033[31m"
#define COLOR_YELLOW "\033[33m"
#define COLOR_RESET "\033[0m"

#define yyerrorf(format, ...)                                                                         \
    {                                                                                                 \
        compileError = true;                                                                          \
        printf(ERROR_PREFIX format, yyInputFileName, yylineno, yycolumn - yyleng + 1, ##__VA_ARGS__); \
        printErrorLine();                                                                             \
        YYABORT;                                                                                      \
    }

static inline void checkNewline(char* str, size_t len) {
    if (str[len - 1] != '\n') {
        str[len] = '\n';
        str[len + 1] = 0;
    }
}

void printErrorLine() {
    // Read error line
    fseek(yyin, yyoffset - yycolumn, SEEK_SET);
    char cache[ERROR_TEXT_BUFFER_LEN + 2], token[ERROR_TOKEN_BUFFER_LEN + 1];
    cache[0] = 0;
    fgets(cache, ERROR_TEXT_BUFFER_LEN, yyin);
    checkNewline(cache, strlen(cache));
    int startIndex = yycolumn - yyleng;
    memcpy(token, cache + (startIndex), yyleng);
    token[yyleng] = 0;
    cache[startIndex] = 0;
    printf("%6d |%s" COLOR_RED "%s" COLOR_RESET "%s", yylineno, cache, token, cache + yycolumn);
    printf("       |%*.s" COLOR_RED "^", startIndex, "");
    for (size_t i = 1; i < yyleng; i++) printf("~");
    printf(COLOR_RESET "\n");
    // Read next error line
    cache[0] = 0;
    fgets(cache, ERROR_TEXT_BUFFER_LEN, yyin);
    size_t len = strlen(cache);
    if (!len) return;
    checkNewline(cache, len);
    printf("%6d |%s", yylineno + 1, cache);
}

void yyerror(char const* msg) {
    compileError = true;

    printf(ERROR_PREFIX " %s\n", yyInputFileName, yylineno, yycolumn - yyleng + 1, msg);
    printErrorLine();
}

#endif