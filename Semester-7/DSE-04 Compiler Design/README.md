# DSC-19: Compiler Design - Practicals

![Course](https://img.shields.io/badge/Course-DSC--19-blue.svg?style=for-the-badge)

Welcome to the collection of practical assignments for the **Compiler Design** course. This repository contains implementations for various lexical and syntax analysis problems using **Lex** and **YACC**.

---

## 🛠️ Environment Setup

This project uses **Lex (Flex)** and **YACC (Bison)**. We recommend using GCC for compilation.

**Quick Setup:**
1.  **Install Flex and Bison:** Ensure Flex, Bison, and GCC are installed on your system.
2.  **Compile and Run:** Use the standard commands to compile and run Lex/YACC programs:
    ```bash
    lex filename.l
    yacc -d filename.y
    gcc lex.yy.c y.tab.c -w
    ./a.out
    ```

---

## 📅 List of Practicals

This repository covers the following practicals:

1.  **[Count Lines and Characters](./practical1.l)** - Write a Lex program to count the number of lines and characters in the input file.
2.  **[Count Vowels](./practical2.l)** - Lex program to count the number of vowels in a given string.
3.  **[Caesar Cipher](./practical3.l)** - Write a Lex program that implements the Caesar cipher.
4.  **[Longest Word](./practical4.l)** - Write a Lex program that finds the longest word in the input.
5.  **[Token Recognition](./practical5.l)** - Write a Lex program that distinguishes keywords, integers, floats, identifiers, operators, and comments.
6.  **[Count Words, Characters, Blanks, Lines](./practical6.l)** - Write a Lex program to count the number of words, characters, blank spaces and lines in a C file.
7.  **[Pattern Output](./practical7.l)** - Write a Lex specification program that generates a C program which takes a string "abcd" and prints a specific pattern.
8.  **[Arithmetic Expression Recognition (Lex)](./practical8.l)** - A program in Lex to recognize a valid arithmetic expression.
9.  **[Expression Validity and Variable Recognition (YACC)](./practical9.y)** - Write a YACC program to find the validity of a given expression and recognize a valid variable.
10. **[Simple Calculator (YACC)](./practical10.y)** - A Program in YACC to evaluate an expression (addition, subtraction, multiplication, division).
11. **[Language Recognition 1 (YACC)](./practical11.y)** - Program in YACC to recognize the string 'abbb', 'ab', 'a' of the language (a^n b^n, n>=1).
12. **[Language Recognition 2 (YACC)](./practical12.y)** - Program in YACC to recognize the language (a^n b, n>=10).

---
<p align="right">
  <i>Developed with ❤️ by <a href="https://github.com/16ratneshkumar">16ratneshkumar</a></i>
</p>
