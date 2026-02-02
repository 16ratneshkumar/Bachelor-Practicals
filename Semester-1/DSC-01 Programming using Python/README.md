# DSC-01: Programming using Python - Practicals

[![Course](https://img.shields.io/badge/Course-DSC--01-blue.svg?style=for-the-badge)](https://www.du.ac.in/)

Welcome to the collection of practical assignments for the **Programming using Python** course. This repository contains implementations for both the 2023-24 session and the 2024 onwards curriculum.

---

### 📅 Session: 2023-24

1. [Write a program to find the roots of a quadratic equation.](./2023%2024/1.py)
2. [Write a program to accept a number ‘n’ and:](./2023%2024/2.py)
    1. Check if ’n’ is prime 
    2. Generate all prime numbers till ‘n’  
    3. Generate first ‘n’ prime numbers  
    
    This program may be done using functions.
3. [Write a program to create a pyramid of the character ‘*’ and a reverse pyramid.](./2023%2024/3.py)
    ```
        *
       ***
      *****
     *******
    *********
    ```
4. [Write a program that accepts a character and performs the following:](./2023%2024/4.py)
    1. print whether the character is a letter or numeric digit or a special character. 
    2. if the character is a letter, print whether the letter is uppercase or lowercase 
    3. if the character is a numeric digit, prints its name in text (e.g., if input is 9, output is NINE) 
5. [Write a program to perform the following operations on a string:](./2023%2024/5.py)
    1. Find the frequency of a character in a string. 
    2. Replace a character by another character in a string. 
    3. Remove the first occurrence of a character from a string. 
    4. Remove all occurrences of a character from a string. 
6. [Write a program to swap the first n characters of two strings.](./2023%2024/6.py)
7. [Write a function that accepts two strings and returns the indices of all the occurrences of the second string in the first string as a list. If the second string is not present in the first string then it should return -1.](./2023%2024/7.py)
8. [Write a program to create a list of the cubes of only the even integers appearing in the input list (may have elements of other types also) using the following:](./2023%2024/8.py)
    1. 'for' loop 
    2. list comprehension 
9. [Write a program to read a file and:](./2023%2024/9.py)
    1. Print the total number of characters, words and lines in the file. 
    2. Calculate the frequency of each character in the file. Use a variable of dictionary type to maintain the count. 
    3. Print the words in reverse order. 
    4. Copy even lines of the file to a file named ‘File1’ and odd lines to another file named ‘File2’.
10. [Write a program to define a class "2DPoint" with coordinates x and y as attributes. Create relevant methods and print the objects. Also define a method distance to calculate the distance between any two point objects.](./2023%2024/10.py)
11. [Write a function that prints a dictionary where the keys are numbers between 1 and 5 and the values are cubes of the keys.](./2023%2024/11.py)
12. [Consider a tuple t1=(1, 2, 5, 7, 9, 2, 4, 6, 8, 10). Write a program to perform following operations:](./2023%2024/12.py)
    1. Print half the values of the tuple in one line and the other half in the next line. 
    2. Print another tuple whose values are even numbers in the given tuple. 
    3. Concatenate a tuple t2=(11,13,15) with t1. 
    4. Return maximum and minimum value from this tuple
13. [Write a program to accept a name from a user. Raise and handle appropriate exception(s) if the text entered by the user contains digits and/or special characters.](./2023%2024/13.py)

---

### 📅 Session: 2024 Onwards

1. [Write a program to find the roots of a quadratic equation.](./2024%20onwards/1.py)
2. [Write a program to accept a number ‘n’ and:](./2024%20onwards/2.py)
    1. Check if ’n’ is prime 
    2. Generate all prime numbers till ‘n’  
    3. Generate first ‘n’ prime numbers  
    
    This program may be done using functions.
3. [Write a program to create a pyramid of the character ‘*’ and a reverse pyramid.](./2024%20onwards/3.py)
4. [Write a program that accepts a character and performs the following:](./2024%20onwards/4.py)
    1. print whether the character is a letter or numeric digit or a special character. 
    2. if the character is a letter, print whether the letter is uppercase or lowercase 
    3. if the character is a numeric digit, prints its name in text (e.g., if input is 9, output is NINE) 
5. [Write a program to perform the following operations on a string:](./2024%20onwards/5.py)
    1. Find the frequency of a character in a string. 
    2. Replace a character by another character in a string. 
    3. Remove the first occurrence of a character from a string. 
    4. Remove all occurrences of a character from a string. 
6. [Write a program to swap the first n characters of two strings.](./2024%20onwards/6.py)
7. [Write a function that accepts two strings and returns the indices of all the occurrences of the second string in the first string as a list. If the second string is not present in the first string then it should return -1.](./2024%20onwards/7.py)
8. [Write a program to create a list of the cubes of only the even integers appearing in the input list (may have elements of other types also) using the following:](./2024%20onwards/8.py)
    1. 'for' loop 
    2. list comprehension 
9. [Write a program to read a file and:](./2024%20onwards/9.py)
    1. Print the total number of characters, words and lines in the file. 
    2. Calculate the frequency of each character in the file. Use a variable of dictionary type to maintain the count. 
    3. Print the words in reverse order. 
    4. Copy even lines of the file to a file named ‘File1’ and odd lines to another file named ‘File2’. 
10. [Write a function that prints a dictionary where the keys are numbers between 1 and 5 and the values are cubes of the keys.](./2024%20onwards/10.py)
11. [Consider a tuple t1=(1, 2, 5, 7, 9, 2, 4, 6, 8, 10). Write a program to perform following operations:](./2024%20onwards/11.py)
    1. Print half the values of the tuple in one line and the other half in the next line. 
    2. Print another tuple whose values are even numbers in the given tuple. 
    3. Concatenate a tuple t2=(11,13,15) with t1. 
    4. Return maximum and minimum value from this tuple 
12. [Define a class Employee that stores information about employees in the company. The class should contain the following:](./2024%20onwards/12.py)
    1) data members- count (to keep a record of all the objects being created for this class) and for every employee: an employee number, Name, Dept, Basic, DA and HRA.                                   
    2) function members: 
        1. __init__ method to initialize and/or update the members. Add statements to ensure that the program is terminated if any of Basic, DA and HRA is set to a negative value. 
        2. function salary, that returns salary as the sum of Basic, DA and HRA. 
        3. __del__ function to decrease the number of objects created for the class. 
        4. __str __ function to display the details of an employee along with the salary of an employee in a proper format. 
13. [Write a program to define a class "2DPoint" with coordinates x and y as attributes. Create relevant methods and print the objects. Also define a method distance to calculate the distance between any two point objects.](./2024%20onwards/13.py)
14. [Inherit the above class to create a "3Dpoint" with additional attribute z. Override the method defined in "2DPoint" class , to calculate distance between two points of the "3DPoint" class.](./2024%20onwards/14.py)
15. [Write a program to accept a name from a user. Raise and handle appropriate exception(s) if the text entered by the user contains digits and/or special characters.](./2024%20onwards/15.py)

---
<p align="right">
  <i>Developed with ❤️ by <a href="https://github.com/16ratneshkumar">16ratneshkumar</a></i>
</p>