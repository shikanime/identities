<!-- owner: shikanime | zone: internal | purpose: the local format/check loop and how to add an identity -->

# Development

## Prerequisites

- Nix with flakes enabled.
- `direnv` (the repo ships `.envrc` + a SOPS-enabled dev shell); `direnv allow`
  to load it. An age key for the `secrets/*.enc.yaml` set is required to
  decrypt.
- This is a `jj` repo. Branch off `main`; never commit to `main` directly.

## Build and check loop

```bash
direnv allow        # or: nix develop
nix fmt             # treefmt: Nix formatting + markdown lint (80-col)
nix flake check     # evaluate the flake / module options
```

CI (`.github/workflows/`) runs the format/eval pass on every PR. `nix fmt` must
be clean before a PR is reviewable.

## Coding style

- Nix: 2-space indentation, `with lib;` at the top of each file.
- Commit messages: plain capitalized title, no conventional-commit prefix.
- Keep Markdown wrapped at 80 columns; `nix fmt` enforces it.

## Adding an identity

1. Add `secrets/<name>.enc.yaml` and encrypt the PII with the repo age key.
2. Add `modules/home/<name>.nix` declaring the SOPS secrets and rendering the
   git include + `jj/conf.d/<name>.toml` (and glab/ghstack if needed).
3. Import it from `modules/home/default.nix` and expose
   `identities.<name>.enable`.
4. Set `git.condition` and the JJ `--when.repositories` scope for isolation.
5. `nix fmt`, `nix flake check`, open a PR against `main`.
