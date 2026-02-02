# Write a Python program that simulates a brute-force attack on a password 
# by trying out all possible character combinations.

import itertools
import random

characterList = ['a', 'b', 'c', 'A', 'B', 'C', '1', '2', '3', '@']

def guessPassword(length):
    password = ""
    for i in range(length):
        password += random.choice(characterList)
    return password

def bruteForce(targetPassword, maxLength = 4):
    for len in range(1, maxLength+1):
        for guessTuple in itertools.product(characterList,repeat=len):
            guessPassword = "".join(letter for letter in guessTuple)
            if targetPassword == guessPassword:
                return guessPassword
            
if __name__ == "__main__":
    targetPassword = guessPassword(4)
    maxLength = len(targetPassword) 
    print("Password Found: ",bruteForce(targetPassword, maxLength))