# fsck_hfs — Cache Bug Fix Fork

This fork patches a cache-corruption bug in `BTCheckUnusedNodes` that caused
`fsck_hfs` to hang or produce incorrect results on large HFS+ volumes (≥ 24 TB)
on Macs with low memory (≤ 8 GB RAM). Under these conditions the block cache is
exhausted while scanning unused B-tree nodes, leading to incorrect behaviour.
The function has been rewritten to bypass the block cache entirely and read
unused B-tree nodes directly from disk. See [CHANGES.md](CHANGES.md) for a full change log.

---

## WARNING: Read-Only Mode Required

**Always** run the patched `fsck_hfs` with the `-n` flag (no-write / dry-run mode):

```sh
sudo fsck_hfs -n /dev/diskXsY
```

The fix does **not** handle non-contiguous (fragmented) file extents correctly.
When `MapFileBlockC` reports `contiguousBytes < nodeSize`, the target node spans
two or more extents that are not laid out consecutively on disk. In that case the
raw read covers only the first fragment and the remaining bytes will be garbage,
potentially misidentifying a valid node as corrupt or writing incorrect data back
to disk.

For the most common failure case (the Attributes B-tree on a single-extent
volume) this is not a problem. But on fragmented volumes the `-n` flag is the
only safe option until full fragmented-extent support is implemented.

> **Using `fsck_hfs` without `-n` on a fragmented volume could cause data
> corruption or loss.**

---

## How to Build

**Prerequisites:**
- macOS with Xcode command-line tools installed
- A public Xcode SDK (`macosx`)

### Option 1 — Make (recommended)

```sh
cd hfs-src-main/
make        # produces fsck_hfs/fsck_hfs
make clean  # removes objects and the binary
```

### Option 2 — Xcode

```sh
xcodebuild -target fsck_hfs -configuration Debug
```

> If the binary is killed immediately on launch (`zsh: killed`), open the project
> settings for the `fsck_hfs` target, go to **Build Settings → Code Signing
> Entitlements**, and clear the value for the macOS SDK. See
> [CHANGES.md](CHANGES.md) § "Empty macOS entitlements" for details.

---

## How to Use

**1. Identify the HFS+ partition device node:**

```sh
diskutil list
```

**2. Unmount the volume** (do not eject — the disk must remain accessible):

```sh
diskutil unmount /dev/diskXsY
```

**3. Run in read-only mode (safe, recommended):**

```sh
sudo fsck_hfs -n /dev/diskXsY
```

With verbose output:

```sh
sudo fsck_hfs -n -f -d /dev/diskXsY
```

**4. Repair mode** — only after confirming the volume is not fragmented and
understanding the caveat in the warning above:

```sh
sudo fsck_hfs -fy /dev/diskXsY
```

**5. Remount when done:**

```sh
diskutil mount /dev/diskXsY
```
