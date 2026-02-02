# Application Of Linear Algebra: Coding And Decoding Of Messages Using Non Singular Matrices.
# Eg Code “Linear Algebra Is Fun” And Then Decode It.

import numpy as np

# Function to encode a message using a non-singular matrix
def encode_message(message, matrix):
    # Convert message to numbers (A=0, B=1, ..., Z=25)
    message_numbers = [ord(char) - ord('A') for char in message]
    
    # Reshape message into a column vector
    message_vector = np.array(message_numbers).reshape(-1, 1)
    
    # Encode the message using matrix multiplication
    encoded_message = np.dot(matrix, message_vector)
    return encoded_message

# Function to decode a message using the inverse of the encoding matrix
def decode_message(encoded_message, matrix):
    # Compute the inverse of the encoding matrix
    matrix_inv = np.linalg.inv(matrix)
    
    # Decode the message using matrix multiplication
    decoded_message_vector = np.dot(matrix_inv, encoded_message)
    
    # Convert the numbers back to letters
    decoded_message = ''.join([chr(int(round(num)) + ord('A')) for num in decoded_message_vector.flatten()])
    return decoded_message

def main():
    # Define a non-singular matrix (3x3 matrix for encoding)
    encoding_matrix = np.array([[1, 2, 3], [0, 1, 4], [5, 6, 0]])
    
    # The message to encode (Make sure the message length matches the matrix size)
    message = "HELLO"
    
    # Make sure the message length matches the matrix dimensions (adjust accordingly)
    message = message[:3]  # Shorten message to fit 3x3 matrix (adjust based on your matrix size)
    
    # Encode the message
    encoded_message = encode_message(message, encoding_matrix)
    print(f"Encoded Message (in numbers):\n{encoded_message}")
    
    # Decode the message
    decoded_message = decode_message(encoded_message, encoding_matrix)
    print(f"Decoded Message: {decoded_message}")

if __name__ == "__main__":
    main()
