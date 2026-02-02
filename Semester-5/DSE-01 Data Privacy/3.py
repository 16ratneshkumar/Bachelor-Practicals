# Write a Python program that defines a function and takes a password string as input 
# and returns its SHA-256 hashed representation as a hexadecimal string.

import hashlib

def hashSha256(password):
    encodePassword = password.encode()
    hashPassword = hashlib.sha256(encodePassword)
    return hashPassword.hexdigest()

if __name__ == "__main__":
    password = str(input("Enter Password: "))
    print("SHA-256 Hashed Password: ", hashSha256(password))