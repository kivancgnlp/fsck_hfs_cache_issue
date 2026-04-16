# Changes for Public Build Compatibility

## New Files

### `fsck_hfs/version.c`
Apple's build system (`buildit`/`xbs`) auto-generates a version string symbol
`fsck_hfsVersionString` from project metadata. This symbol is declared `extern`
in `lib_fsck_hfs/dfalib/SControl.c` and is not present anywhere in the source
tree, so standalone `make` builds fail at link time with:

    Undefined symbols: _fsck_hfsVersionString

This file provides a stub definition in the expected format:

    "@(#)PROGRAM:fsck_hfs  PROJECT:hfs-<version>\n"

Note: Xcode generates its own `version.o` automatically, so this file is
intentionally excluded from the Xcode target and is only used by the Makefile.

---

### `Makefile`
A standalone Makefile placed in `hfs-src-main/` that mirrors the `fsck_hfs`
Xcode target. Allows building without Xcode using `make`.

Key differences from the Xcode project:

| Xcode setting                  | Makefile equivalent                          |
|-------------------------------|----------------------------------------------|
| `SDKROOT = macosx.internal`   | `xcrun --show-sdk-path` (public SDK)         |
| Automatic header map          | `-I fsck_hfs -I lib_fsck_hfs -I lib_fsck_hfs/dfalib` |
| Implicit framework linking    | `-framework CoreFoundation -framework IOKit` |
| `GCC_PREPROCESSOR_DEFINITIONS`| `-DBSD=1 -DCONFIG_HFS_TRIM=1 -DDEBUG_BUILD=0` |

Usage:

    cd hfs-src-main/
    make          # produces fsck_hfs/fsck_hfs
    make clean    # removes objects and binary

---

## Modified Files

### `hfs.xcodeproj/project.pbxproj`

#### 1. `SDKROOT`: `macosx.internal` → `macosx`

Changed in all 4 build configurations of the `fsck_hfs` target:

| Configuration UUID                   | Name     |
|--------------------------------------|----------|
| `4DFD93FB1535FF510039B6BA`           | Release  |
| `FBD5C7E11B1D591800B4620E`           | Debug    |
| `070DB02A268FD00800ACF231`           | Fuzzing  |
| `FBD69B201B94E9990022ECAD`           | Coverage |

`macosx.internal` is Apple's private SDK, not available in public Xcode
installations. Changing to `macosx` makes Xcode use the standard public SDK.
No other targets were modified.

#### 2. Removed `FSKit.framework` from the Frameworks build phase

Removed from the `fsck_hfs` Frameworks build phase
(`4DFD93F11535FF510039B6BA`):

    CE8267A92CEF50D20019C139 /* FSKit.framework in Frameworks */

`FSKit` is an Apple-internal framework not shipped with public Xcode. All
FSKit usage in the source is already conditionally compiled:

    #if __has_include(<FSKit/FSKit.h>)
    #define HAS_FSKIT
    ...
    #endif

So the code degrades gracefully when FSKit is absent. Removing the explicit
link dependency lets the target link against the public SDK without errors.
`CoreFoundation.framework` and `IOKit.framework` remain linked.

#### 3. Empty macOS entitlements for Debug and Release configurations

Added to the Debug configuration (`FBD5C7E11B1D591800B4620E`) and Release
configuration (`4DFD93FB1535FF510039B6BA`):

    "CODE_SIGN_ENTITLEMENTS[sdk=macosx*]" = "";

Without this, the Xcode-built binary is killed by macOS immediately on launch
(`zsh: killed`) before reaching `main()`. The cause is that the Release config
applies `fsck_hfs.osx.entitlements` which contains:

    <key>com.apple.rootless.restricted-block-devices</key>
    <true/>

This is a private Apple entitlement that requires a proper Apple signing
certificate to validate. On a locally ad-hoc signed binary, macOS's kernel
sends `SIGKILL` at launch when it finds this entitlement. Setting the macOS
entitlements to empty for Debug builds bypasses this. iOS builds and the
Release configuration are untouched.
