// brain-paths.mjs — the per-OS roots the brain hooks read. **archlinux branch**, tracked in the
// Arch $HOME at ~/.claude/brain-paths.mjs. The hooks run from a `main` checkout at
// ~/dev/AtlasAta-DotFiles, whose hooks/brain-paths.mjs is an untracked symlink to this file:
// archlinux cannot merge `main` (main deletes the Arch $HOME tree).
export const VAULT = "/home/atlasata/knowledge";
export const DEV_ROOT = "/home/atlasata/dev";
