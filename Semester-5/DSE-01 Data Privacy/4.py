# Write a Python program that reads a file containing a list of usernames and passwords,one pair per line (separated by a comma). It checks each password to see if it has been leaked in a data breach. You can use the "Have I Been Pwned" API (https://haveibeenpwned.com/API/v3) to check if a password has been leaked.

import hashlib
import requests

def check_password_pwned(password):
    """
    Check if a password has been exposed using the HIBP Pwned Passwords API.
    Uses k-anonymity: only the first 5 chars of the SHA-1 hash are sent.
    """
    sha1 = hashlib.sha1(password.encode('utf-8')).hexdigest().upper()
    prefix = sha1[:5]
    suffix = sha1[5:]
    # print(prefix)
    print(suffix)
    
    url = f"https://api.pwnedpasswords.com/range/{prefix}"
    response = requests.get(url)
    if response.status_code != 200:
        raise RuntimeError("Error fetching data from HIBP API")

    # print(response.text)
    hashes = (line.split(":") for line in response.text.splitlines())
    for hash_suffix, count in hashes:
        if hash_suffix == suffix:
            print(hash_suffix)
            return int(count)
    return 0

def process_password_file(filename):
    with open(filename, "r") as file:
        for line in file:
            line = line.strip()
            if not line:
                continue
            try:
                username, password = line.split(",", 1)
            except ValueError:
                print(f"Skipping malformed line: {line}")
                continue
            count = check_password_pwned(password)
            if count > 0:
                print(f"[WARNING] {username}: Password found {count} times in breaches!")
            else:
                print(f"[OK] {username}: Password NOT found in any known breach.")


if __name__ == "__main__":
    filename = "Practical/credentials.txt"
    process_password_file(filename)
