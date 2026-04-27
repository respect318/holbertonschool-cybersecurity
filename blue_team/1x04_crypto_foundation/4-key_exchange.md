# The Key Exchange

## Part 1 - The DH Simulation

**1. Generate shared DH parameters:**
`openssl dhparam -out dhparams.pem 2048`
*(Output: Generating DH parameters, 2048 bit long safe prime...)*

**2. Generate Alice's private key from the parameters:**
`openssl genpkey -paramfile dhparams.pem -out alice_private.pem`

**3. Extract Alice's public key:**
`openssl pkey -in alice_private.pem -pubout -out alice_public.pem`

**4. Generate Bob's private key from the parameters:**
`openssl genpkey -paramfile dhparams.pem -out bob_private.pem`

**5. Extract Bob's public key:**
`openssl pkey -in bob_private.pem -pubout -out bob_public.pem`

**6. Derive the shared secret from Alice's side using Bob's public key:**
`openssl pkeyutl -derive -inkey alice_private.pem -peerkey bob_public.pem -out alice_secret.bin`

**7. Derive the shared secret from Bob's side using Alice's public key:**
`openssl pkeyutl -derive -inkey bob_private.pem -peerkey alice_public.pem -out bob_secret.bin`

**8. Compare the two secrets:**
`diff alice_secret.bin bob_secret.bin`
*(Output: No output is returned, confirming both binary files are perfectly identical).*

## Part 2 - The Explanation

Imagine Alice and Bob each have a private, secret paint color, and they agree on a common, public base color over an open channel. They both mix their private color with the public base color and send the resulting mixture to each other. When they receive the other person's mixture, they add their own private color to it. Because the final mixture contains the exact same three components (the base color, Alice's private color, and Bob's private color), they both end up with the exact same final shared secret color without ever sending their original private colors across the network. Eve, listening on the network, only sees the public base color and the intermediate mixtures. Because separating mixed paint (or reversing the complex mathematics used in DH) is practically impossible, Eve cannot deduce the private colors or recreate the final shared secret.

## Part 3 - The MITM Attack

Plain Diffie-Hellman successfully creates a secure shared key, but it natively lacks authentication, meaning Alice and Bob have no way to verify the true identity of the person on the other end. In a man-in-the-middle (MITM) attack, Eve intercepts Alice's public key, gives Bob her own public key instead, and repeats this interception in reverse for Alice. Eve effectively establishes one secure shared secret with Alice and a completely different shared secret with Bob, allowing her to transparently decrypt, read, and re-encrypt all traffic passing between them. If the VPN tunnel between MedDefense's Central and Westside clinics uses DH without authentication, an attacker on the network path could perform this attack to silently intercept and read sensitive patient data in transit. Certificates prevent this vulnerability because they act as digital ID cards verified by a trusted Certificate Authority (CA), allowing Alice and Bob to definitively prove their identities before exchanging keys.
