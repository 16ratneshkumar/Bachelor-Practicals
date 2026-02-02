# Demonstrate the usage/sending of a digitally signed document.

from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization

# -------------------------
# Step 1: Generate keys
# -------------------------
def generate_keys():
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048
    )
    public_key = private_key.public_key()
    
    # Save private key
    with open("private_key.pem", "wb") as f:
        f.write(private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.TraditionalOpenSSL,
            encryption_algorithm=serialization.NoEncryption()
        ))
    
    # Save public key
    with open("public_key.pem", "wb") as f:
        f.write(public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        ))
    
    print("Keys generated and saved to files.")


# -------------------------
# Step 2: Sign a file
# -------------------------
def sign_file(filename, private_key_file="private_key.pem"):
    # Load private key
    with open(private_key_file, "rb") as f:
        private_key = serialization.load_pem_private_key(f.read(), password=None)
    
    # Read file content
    with open(filename, "rb") as f:
        data = f.read()
    
    # Create signature
    signature = private_key.sign(
        data,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    
    # Save signature to file
    sig_file = filename + ".sig"
    with open(sig_file, "wb") as f:
        f.write(signature)
    
    print(f"File '{filename}' signed. Signature saved as '{sig_file}'.")


# -------------------------
# Step 3: Verify a file
# -------------------------
def verify_file(filename, signature_file, public_key_file="public_key.pem"):
    # Load public key
    with open(public_key_file, "rb") as f:
        public_key = serialization.load_pem_public_key(f.read())
    
    # Read file content
    with open(filename, "rb") as f:
        data = f.read()
    
    # Read signature
    with open(signature_file, "rb") as f:
        signature = f.read()
    
    # Verify signature
    try:
        public_key.verify(
            signature,
            data,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        print(f"Signature VALID for file '{filename}'.")
    except Exception as e:
        print(f"Signature INVALID for file '{filename}'. {e}")


# -------------------------
# Example Usage
# -------------------------
if __name__ == "__main__":
    # 1. Generate keys (only once)
    generate_keys()
    
    # 2. Sign a file
    file_to_sign = "Practical/credentials.txt"  # Make sure this file exists
    sign_file(file_to_sign)
    
    # 3. Verify the file
    signature_file = file_to_sign + ".sig"
    verify_file(file_to_sign, signature_file)
