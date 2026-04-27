# The Disk Encryption Lab

## Part 1 - LUKS Setup

**1. Create the virtual disk file:**
```bash
dd if=/dev/zero of=encrypted_volume.img bs=1M count=500
Output: 500+0 records in / 500+0 records out / 524288000 bytes (524 MB, 500 MiB) copied...

2. Format with LUKS:

Bash
sudo cryptsetup luksFormat encrypted_volume.img
Output: WARNING! This will overwrite data on encrypted_volume.img irrevocably. Are you sure? (Type 'yes' in capital letters): YES (followed by password prompt).

3. Open the encrypted volume:

Bash
sudo cryptsetup luksOpen encrypted_volume.img secure_vol
Output: Prompts for the passphrase. Volume is mapped to /dev/mapper/secure_vol.

4. Create a filesystem:

Bash
sudo mkfs.ext4 /dev/mapper/secure_vol
Output: mke2fs 1.45.5... Creating journal (8192 blocks): done. Writing superblocks and filesystem accounting information: done.

5. Mount and write test data:

Bash
sudo mkdir -p /mnt/secure_data
sudo mount /dev/mapper/secure_vol /mnt/secure_data
sudo bash -c 'echo "CONFIDENTIAL BACKUP DATA: DO NOT LEAK" > /mnt/secure_data/test_backup.txt'
6. Unmount and close:

Bash
sudo umount /mnt/secure_data
sudo cryptsetup luksClose secure_vol
Part 2 - Verification
1. Attempting to read the raw file:

Bash
strings encrypted_volume.img | head -50
Output: Only random, unreadable characters and ciphertext are displayed. The string "CONFIDENTIAL BACKUP DATA" is completely invisible.
Explanation: This proves that encryption at rest completely obscures the raw data blocks on the physical media. Without the decryption key to open the LUKS header, the filesystem structure and all stored files are indistinguishable from random noise, protecting data from physical theft or unauthorized offline access.

2. The full open-mount-read-unmount-close cycle:

Bash
# Open and Mount
sudo cryptsetup luksOpen encrypted_volume.img secure_vol
sudo mount /dev/mapper/secure_vol /mnt/secure_data

# Read and Verify
cat /mnt/secure_data/test_backup.txt
# Output: CONFIDENTIAL BACKUP DATA: DO NOT LEAK

# Unmount and Close
sudo umount /mnt/secure_data
sudo cryptsetup luksClose secure_vol
Part 4 - MedDefense Backup Encryption Design
Encryption Level: Volume-level encryption (or Full-Disk Encryption, FDE) is the most appropriate for the Synology NAS. Unlike file-level encryption, which relies on individual backup scripts to correctly encrypt files before sending them, volume-level encryption ensures that everything written to the NAS storage array is automatically and transparently encrypted without modifying the backup software's workflow.

Performance Impact: Based on the T1 performance measurements (encrypting 100MB in ~0.08s with AES-GCM), the cryptographic overhead of AES-256 is negligible due to modern CPU hardware acceleration (AES-NI). For the NAS backups, network bandwidth (1Gbps/10Gbps LAN) and mechanical disk I/O will be the primary bottlenecks, not the encryption process itself. The performance drop will likely be less than 5%.

Key Storage: The encryption key must NOT be stored on the NAS itself (e.g., Synology Key Manager on local USB or internal drive). If a ransomware actor compromises the NAS (as proven in 1x01), or a thief physically steals the NAS box, they will acquire both the encrypted data and the key to unlock it. The key should be stored in a centralized, heavily restricted Key Management Server (KMS) or an offline, physical safe accessible only by the IT Director.

Lost Key Implications: LUKS and modern FDE systems do not have "backdoors". If the key (or the passphrase to decrypt the key slot) is permanently lost, the backup data is cryptographically shredded and 100% unrecoverable. MedDefense would completely lose its ability to restore systems in the event of a disaster.

Offsite Backup Replication Integration: To integrate securely with the offsite cloud replication control from the 1x03 strategy, the backups must be strictly "client-side encrypted" before they are synchronized to the cloud. This means MedDefense encrypts the data using MedDefense's own keys before it leaves the local network. Under no circumstances should the cloud provider hold the decryption keys; maintaining a Zero-Knowledge architecture ensures that even if the cloud provider is breached or subpoenaed, MedDefense's patient data remains perfectly secure.
