# Write a program to perform encryption and decryption 
# using Caesar cipher (substitutional cipher).

def caesar_encrypt(plaintext, shift):
    encrypted = ""
    for char in plaintext:
        if char.isupper():
            encrypted += chr((ord(char)- 65 + shift) % 26 + 65)
        else:
            encrypted+= char
    return encrypted


def caesar_decrypt(ciphertext, shift):
    plaintext = ""
    for char in ciphertext:
        if char.isupper():
            plaintext+= chr((ord(char)- 65 -shift)% 26 + 65)
        else:
            plaintext+= char
    return plaintext

plaintext = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789"
shift = 3
ciphertext = caesar_encrypt(plaintext, shift)
print("Encrypted:", ciphertext)
decrypted_text = caesar_decrypt(ciphertext, shift)
print("Decrypted:", decrypted_text)