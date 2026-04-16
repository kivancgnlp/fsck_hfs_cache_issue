# Makefile for fsck_hfs
# Run from this directory (hfs-src-main/): make fsck_hfs
#
# Mirrors the Xcode target "fsck_hfs" from hfs.xcodeproj.
# Preprocessor defines and warning flags taken from the Xcode build settings.

CC      = clang
SDK     = $(shell xcrun --show-sdk-path)

CFLAGS  = -isysroot $(SDK) \
          -DBSD=1 \
          -DCONFIG_HFS_TRIM=1 \
          -DDEBUG_BUILD=0 \
          -Wall -W \
          -Wno-missing-field-initializers \
          -Wformat-nonliteral \
          -I fsck_hfs \
          -I lib_fsck_hfs \
          -I lib_fsck_hfs/dfalib

LDFLAGS = -isysroot $(SDK) \
          -framework CoreFoundation \
          -framework IOKit

# ---------------------------------------------------------------------------
# Source files (matches the Xcode Sources build phase for the fsck_hfs target)
# ---------------------------------------------------------------------------

SRCS_FSCK = \
    fsck_hfs/fsck_hfs.c \
    fsck_hfs/fsck_messages.c \
    fsck_hfs/utilities.c \
    fsck_hfs/version.c

SRCS_LIB = \
    lib_fsck_hfs/lib_fsck_hfs.c \
    lib_fsck_hfs/check.c \
    lib_fsck_hfs/cache.c \
    lib_fsck_hfs/fsck_debug.c \
    lib_fsck_hfs/fsck_journal.c \
    lib_fsck_hfs/fsck_strings.c \
    lib_fsck_hfs/fsck_hfs_strings.c

SRCS_DFALIB = \
    lib_fsck_hfs/dfalib/SControl.c \
    lib_fsck_hfs/dfalib/BlockCache.c \
    lib_fsck_hfs/dfalib/BTree.c \
    lib_fsck_hfs/dfalib/BTreeAllocate.c \
    lib_fsck_hfs/dfalib/BTreeMiscOps.c \
    lib_fsck_hfs/dfalib/BTreeNodeOps.c \
    lib_fsck_hfs/dfalib/BTreeScanner.c \
    lib_fsck_hfs/dfalib/BTreeTreeOps.c \
    lib_fsck_hfs/dfalib/CatalogCheck.c \
    lib_fsck_hfs/dfalib/dirhardlink.c \
    lib_fsck_hfs/dfalib/HardLinkCheck.c \
    lib_fsck_hfs/dfalib/hfs_endian.c \
    lib_fsck_hfs/dfalib/SAllocate.c \
    lib_fsck_hfs/dfalib/SBTree.c \
    lib_fsck_hfs/dfalib/SCatalog.c \
    lib_fsck_hfs/dfalib/SDevice.c \
    lib_fsck_hfs/dfalib/SExtents.c \
    lib_fsck_hfs/dfalib/SKeyCompare.c \
    lib_fsck_hfs/dfalib/SRebuildBTree.c \
    lib_fsck_hfs/dfalib/SRepair.c \
    lib_fsck_hfs/dfalib/SStubs.c \
    lib_fsck_hfs/dfalib/SUtils.c \
    lib_fsck_hfs/dfalib/SVerify1.c \
    lib_fsck_hfs/dfalib/SVerify2.c \
    lib_fsck_hfs/dfalib/uuid.c \
    lib_fsck_hfs/dfalib/VolumeBitmapCheck.c

SRCS    = $(SRCS_FSCK) $(SRCS_LIB) $(SRCS_DFALIB)
OBJS    = $(SRCS:.c=.o)
TARGET  = fsck_hfs/fsck_hfs

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET)
