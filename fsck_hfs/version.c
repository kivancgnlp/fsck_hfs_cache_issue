/*
 * version.c - Build version string for fsck_hfs.
 *
 * In Apple's official build system, this symbol is generated automatically
 * by buildit/xbs from the project's version info. For standalone/open-source
 * builds, we provide a placeholder here.
 *
 * The format expected by SControl.c is:
 *   "@(#)PROGRAM:fsck_hfs  PROJECT:hfs-<version>\n"
 */
const unsigned char fsck_hfsVersionString[] =
    "@(#)PROGRAM:fsck_hfs  PROJECT:hfs-local-build\n";
