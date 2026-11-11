# Encrypted NixOS install (LUKS2 + Secure Boot + TPM2)

How to set up a new machine so that:

- the **whole system** (root and /home) is encrypted with LUKS2,
- **Secure Boot** is on, with our own keys (lanzaboote),
- the disk **unlocks by itself through the TPM**, but only when the machine boots
  our signed NixOS with Secure Boot on. Otherwise it asks for the passphrase or
  recovery key.

> Why encrypt root and not just /home: with root unencrypted, someone with the
> laptop can edit the system files (or copy the Secure Boot keys in
> `/var/lib/sbctl`) and get the TPM to unlock /home for them. TPM auto-unlock is only
> safe when everything it boots is encrypted too.

Layout used below:

| partition | label         | what                                  |
| --------- | ------------- | ------------------------------------- |
| p1        | `NIXBOOT`     | 1 GiB EFI partition (vfat, unencrypted, only signed files) |
| p2        | `crypt-root`  | LUKS2, opens as `/dev/mapper/crypt-root` |
| (inside)  | `NIXROOT`     | ext4, `/`, contains /home and the swapfile |

Replace `<host>` with the machine's name throughout.

---

## 0. Before you start

- Back up anything you need from the target disk. **Step 2 erases it.**
- Know where the recovery key will go (password manager / paper), not the laptop.
- Know the BIOS supervisor password if one is set.

## 1. BIOS: turn Secure Boot off

The NixOS installer isn't signed with our keys, so it can't boot with Secure Boot on.
ThinkPad: **F1** at the logo → Security → Secure Boot → **Off** → F10.

Boot the NixOS installer USB. Get online with `nmtui` if needed.

## 2. Partition (erases the disk)

```bash
lsblk                       # find the right disk, double-check it
DISK=/dev/nvme0n1           # <-- the disk to wipe

sudo parted "$DISK" -- mklabel gpt
sudo parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
sudo parted "$DISK" -- set 1 esp on
sudo parted "$DISK" -- mkpart root 1GiB 100%
```

NVMe partitions are `${DISK}p1`, `${DISK}p2`. For SATA disks (`/dev/sda`) drop the `p`.

## 3. Encrypt and format

```bash
sudo mkfs.fat -F 32 -n NIXBOOT "${DISK}p1"

# pick a strong passphrase: it's the fallback when the TPM refuses
sudo cryptsetup luksFormat \
  --type luks2 \
  --label crypt-root \
  --pbkdf argon2id \
  --pbkdf-memory 524288 \
  "${DISK}p2"

sudo cryptsetup open "${DISK}p2" crypt-root
sudo mkfs.ext4 -L NIXROOT /dev/mapper/crypt-root
```

## 4. Mount

```bash
sudo mount /dev/disk/by-label/NIXROOT /mnt
sudo mkdir -p /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/NIXBOOT /mnt/boot
```

## 5. Config

```bash
sudo nixos-generate-config --root /mnt

sudo mkdir -p /mnt/home/noornee/.config
sudo nix-shell -p git --run "git clone https://github.com/noornee/nixdots /mnt/home/noornee/.config/dotfiles"
cd /mnt/home/noornee/.config/dotfiles
```

1. Create `hosts/<host>/` and copy the generated hardware config into it:
   `sudo cp /mnt/etc/nixos/hardware-configuration.nix hosts/<host>/`
   - It should contain `boot.initrd.luks.devices."crypt-root".device = ...` (it does
     this because crypt-root is open). Check it's there.
   - Add a swapfile if wanted: `swapDevices = [{ device = "/var/lib/swapfile"; size = 10 * 1024; }];`
2. Base `hosts/<host>/configuration.nix` on `hosts/thinkpad/configuration.nix`, but:
   - **drop** the `fileSystems."/home"` block and the `crypt-home` LUKS entry (/home now
     lives on root),
   - add TPM unlock for root:
     ```nix
     boot.initrd.luks.devices."crypt-root".crypttabExtraOpts = [ "tpm2-device=auto" ];
     ```
   - keep the `lanzaboote` block (including `settings.editor = false`, so nobody can edit
     the kernel command line at the boot menu), `systemd-boot.enable = lib.mkForce false;`
     and `sbctl`.
3. In `flake.nix` add `nixosConfigurations.<host>` (copy the thinkpad one) and a
   `homeConfigurations."noornee@<host>"` entry.
4. `sudo nix-shell -p git --run "git add -A"` (flakes ignore files git doesn't know about).

## 6. Secure Boot keys (before installing)

Lanzaboote signs the boot files during the install, so the keys must exist first.
Create them inside the new system:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run nixpkgs#sbctl -- \
  create-keys -d /mnt/var/lib/sbctl -e /mnt/var/lib/sbctl/keys

sudo ls /mnt/var/lib/sbctl/keys     # should show PK  KEK  db
```

## 7. Install

```bash
sudo nixos-install --flake /mnt/home/noornee/.config/dotfiles#<host>
# it asks for a root password at the end

sudo nixos-enter --root /mnt -c 'passwd noornee'
sudo nixos-enter --root /mnt -c 'chown -R noornee:users /home/noornee'
```

**If the install fails at "Installing Lanzaboote"**: temporarily set
`boot.lanzaboote.enable = lib.mkForce false;` and `boot.loader.systemd-boot.enable = lib.mkForce true;`,
install, boot, run `sudo sbctl create-keys`, revert those two lines and
`sudo nixos-rebuild switch`. Then continue at step 9.

## 8. First boot

Reboot, remove the USB. It asks for the LUKS passphrase (the TPM isn't set up yet).
Log in, then:

```bash
home-manager switch --flake ~/.config/dotfiles#noornee@<host>
```

## 9. Check signing

```bash
sudo sbctl verify
```

`BOOTX64.EFI`, `systemd-bootx64.efi` and `nixos-generation-*.efi` must be **signed**.
`kernel-*.efi` showing unsigned is expected. Also check `bootctl status` lists
"Linux Boot Manager" → `/EFI/systemd/systemd-bootx64.efi`.

## 10. BIOS: Setup Mode + Secure Boot on

F1 → Security → Secure Boot:

1. **Secure Boot → On**
2. **Reset to Setup Mode**
   ⚠️ **never "Clear All Secure Boot Keys"**: it wipes the dbx (blocked-bootloader
   list), which can't be restored.
3. F10 save and exit. It still boots (no keys enrolled = nothing checked).

## 11. Enroll our keys

```bash
sudo sbctl status                # Setup Mode: Enabled

# efivarfs marks these read-only; unlock just these two (resets on reboot)
sudo chattr -i /sys/firmware/efi/efivars/KEK-* /sys/firmware/efi/efivars/db-*

# --microsoft is required: firmware and option ROMs are signed by Microsoft
sudo sbctl enroll-keys --microsoft
sudo sbctl status                # Setup Mode: Disabled
```

Reboot, then:

```bash
bootctl status | grep -i "secure boot"     # Secure Boot: enabled (user)
ls -l /sys/firmware/efi/efivars/dbx-*      # several KB, not empty
```

## 12. Recovery key

```bash
sudo systemd-cryptenroll --recovery-key /dev/disk/by-label/crypt-root
```

Save it **off the machine** right away (it's shown only once). Test it:

```bash
sudo cryptsetup open --test-passphrase -v /dev/disk/by-label/crypt-root   # paste it
```

## 13. TPM2 auto-unlock

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-label/crypt-root
```

PCR 7 = "Secure Boot is on with these keys". Kernel updates don't affect it; booting a
USB or turning Secure Boot off makes the TPM refuse.

Reboot: it should unlock without a prompt. Final check:

```bash
sudo systemd-cryptenroll /dev/disk/by-label/crypt-root
# 0 password, 1 recovery, 2 tpm2   (nothing else)
```

---

## When things go wrong

| problem | fix |
| --- | --- |
| won't boot after turning Secure Boot on | BIOS → Secure Boot **Off**, boot, run `sudo sbctl verify` and find what's unsigned |
| asks for passphrase after a BIOS/firmware update | normal (PCR 7 changed). Type the passphrase, then re-seal: `sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-label/crypt-root` |
| forgot passphrase | unlock with the recovery key, then `sudo cryptsetup luksAddKey /dev/disk/by-label/crypt-root` for a new one |
| want the factory state back | BIOS → Secure Boot → **Restore Factory Keys** (Lenovo's keys) |
| TPM unlock during boot is slow/fails | `journalctl -b -u systemd-cryptsetup@crypt-root` |

Back up `/var/lib/sbctl` somewhere safe (encrypted). Without it, a reinstall means
re-enrolling new keys (steps 10-11 again), which is fine but more work.
