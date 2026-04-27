# Hash Analysis

## Part 1 - The Avalanche Effect

**SHA-256 Hashes:**
`echo -n "MedDefense" | sha256sum` -> `78e1b6de019e0cc376174a7b54a7ea39e0802c676f4e1f86f34f6bbda9cb1d92`
`echo -n "MedDefense1" | sha256sum` -> `39d1b092fb138090b8f060d4b9ed8bafeb31baf10c5c643be52a0a2df33be14b`
*Comparison:* 63 out of 64 hex characters differ.

**MD5 Hashes:**
`echo -n "MedDefense" | md5sum` -> `9d3d5267d3419bb6aeb41d01dd395ce6`
`echo -n "MedDefense1" | md5sum` -> `c19b22416f5c814b744bf8330725c4fb`
*Comparison:* All 32 hex characters differ.

## Part 2 - Hash Collisions and the Birthday Problem

* **MD5 possible unique outputs:** 2^128
* **SHA-256 possible unique outputs:** 2^256

**Explanation:**
A shorter hash has fewer possible unique outputs, making it statistically much more likely for two different inputs to produce the exact same hash (a collision). A birthday attack exploits the mathematical probability that in a given set, collisions occur much faster than intuition suggests (e.g., only 23 people needed for a 50% chance of a shared birthday); in cryptography, finding a collision in an n-bit hash requires only 2^(n/2) operations. If MedDefense's Active Directory uses RC4 for Kerberos (which relies on MD4 internally), the practical implication is that attackers can easily crack intercepted Kerberos tickets offline using modern hardware, fully compromising user passwords.

## Part 3 - Rainbow Table Demonstration

**MD5 without salt:**
`echo -n "password123" | md5sum` -> `482c811da5d5b4bc6d497ffa98491e38`
*Crackstation Result:* Found (Result: "password123", Type: MD5).

**MD5 with salt:**
`echo -n "s4lt9xQ2:password123" | md5sum` -> `0e7ed8de6d0fb4c728e2ad3b0a9960cd`
*Crackstation Result:* Not found (Unrecognized hash).

**Explanation:**
Salting defeats rainbow tables because these tables consist of precomputed hashes strictly for common, known passwords. By appending a random string (the salt) to the password before hashing, the resulting hash becomes completely unique, rendering the precomputed table useless. Every user needs a unique salt so that if multiple users share the identical password, their database hashes will still be completely different, preventing attackers from identifying duplicate passwords.

## Part 4 - Key Stretching

**bcrypt:**
Bcrypt is a password hashing function derived from the Blowfish cipher that incorporates a salt by default. It utilizes a "cost factor" parameter that exponentially increases the number of key expansion iterations, intentionally slowing down the hashing process to make hardware-accelerated brute-force attacks highly inefficient.

**PBKDF2:**
Password-Based Key Derivation Function 2 repeatedly applies a pseudorandom function (like HMAC-SHA256) to the password and salt combination. Its "iteration count" controls how many thousands of times this function loops, increasing the time cost to resist brute-force attempts, though it remains more vulnerable to GPU/ASIC attacks than memory-hard algorithms.

**Argon2:**
Argon2 (the winner of the Password Hashing Competition) is specifically designed to be memory-hard rather than just computationally hard. Its parameters dictate time cost (iterations), parallelism, and most importantly, memory cost, making it exceptionally resistant to specialized cracking hardware like ASICs and GPUs that lack large amounts of fast memory.

**Recommendations & Active Directory Default:**
I would recommend **Argon2 (specifically Argon2id)** for MedDefense's application password storage because it provides the highest resistance against both CPU and GPU-based brute-force attacks by requiring significant memory overhead. 

By default, Active Directory uses **NTHash** (often mistakenly called NTLM hash), which is simply the MD4 hash of the UTF-16LE encoded password. It is completely **inadequate** because it uses a broken, extremely fast algorithm (MD4) with absolutely no salting and no iterations, making it trivial to crack offline or exploit via pass-the-hash attacks.
