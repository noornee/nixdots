# Encrypt /home partition with LUKS2 using Argon2id
# Partition: /dev/nvme0n1p3

```bash
sudo cryptsetup luksFormat \
  --type luks2 \
  --label crypt-home \
  --pbkdf argon2id \
  --pbkdf-memory 524288 \
  /dev/nvme0n1p3

# Open encrypted partition
sudo cryptsetup open /dev/nvme0n1p3 crypt-home

# Format as ext4 and label it
sudo mkfs.ext4 -L HOME /dev/mapper/crypt-home

# Check block devices
lsblk -f

# Mount to /mnt/home temporarily
sudo mkdir -p /mnt/home
sudo mount /dev/mapper/crypt-home /mnt/home

# Create secure key directory
sudo mkdir -p /etc/keys
sudo chmod 700 /etc/keys

# Generate random keyfile for automated unlocking
sudo dd if=/dev/urandom of=/etc/keys/home.key bs=1 count=4096
sudo chmod 400 /etc/keys/home.key

# Add keyfile to LUKS partition
sudo cryptsetup luksAddKey /dev/nvme0n1p3 /etc/keys/home.key
```
