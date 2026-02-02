# Write a program to perform encryption and decryption 
# using Rail Fence cipher (Transpositional cipher).

def rail_fence_encrypt(text, key):
    rail = ['' for _ in range(key)]
    print(rail)
    row = 0 
    direction = 1
    for char in text:
        rail[row] += char
        if row == 0:
            direction = 1
        elif row == key - 1:
            direction = -1
        row += direction
    return ''.join(rail)


def rail_fence_decrypt(cipher, key):
    pattern = [[] for _ in range(key)]
    row = 0
    direction = 1
    for _ in cipher:
        pattern[row].append('*')  
        if row == 0:
            direction = 1
        elif row == key - 1:
            direction = -1
        row += direction
    index = 0
    for r in range(key):
        for c in range(len(pattern[r])):
            pattern[r][c] = cipher[index]
            index += 1
    result = ""
    row = 0
    direction = 1
    for _ in cipher:
        result += pattern[row].pop(0)
        if row == 0:
            direction = 1
        elif row == key - 1:
            direction = -1
        row += direction
    return result


if __name__ == "__main__":
    message = "IAMRATNESHKUMAR"
    key = 3
    encrypted = rail_fence_encrypt(message, key)
    print("Encrypted:", encrypted)
    decrypted = rail_fence_decrypt(encrypted, key)
    print("Decrypted:", decrypted)
