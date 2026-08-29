<!-- owner: shikanime | zone: internal | purpose: known failure modes and the first-responder fix for each -->

# Troubleshooting

## Identity fragment never applies

**Symptom:** enabling `identities.<name>.enable` changes nothing in the built
config. **Cause:** the consumer did not enable the tool (`programs.git`,
`programs.jujutsu`). **Fix:** enable the tool in the consumer; this repo only
emits fragments and never turns tools on.

## One identity leaks into another repo

**Symptom:** `gouv` commits appear under `shikanime` repos, or vice versa.
**Cause:** `git.condition` / `jj.extraConfig."--when".repositories` scoping is
missing or wrong. **Fix:** set `identities.<name>.git.condition` (a `gitpath:`
match) and the JJ repository list in the identity module.

## SOPS decrypt fails

**Symptom:** `nix flake check` / build errors decrypting `secrets/*.enc.yaml`.
**Cause:** the age key is not in the local keychain. **Fix:** install the repo
age key (`age1pwl9...v3z3g`); confirm `sops` can open the file before
rebuilding.

## `nix fmt` fails on a docs page

**Cause:** treefmt's rumdl-check rejects Markdown lines over 80 columns.
**Fix:** wrap the offending lines to ≤80 and re-run `nix fmt` until clean.
