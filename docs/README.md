<!-- owner: shikanime | zone: internal | purpose: docs landing + index for the identities Nix module repo -->

# Identities — Documentation

Nix flake modules that keep persona/PII in one place and emit only the small
config fragments each tool needs (`git` includes, `jj` conf.d, glab/ghstack).
The modules do **not** enable or configure the VCS tools — they only write
identity snippets, so they drop into an existing Home Manager setup.

## Internal ops

- [Architecture](./Architecture.md) — the identity module tree and why fragments
  stay isolated per `git.condition` / `jj` repo scope.
- [Development](./Development.md) — local setup, the format/check loop, and how
  to add an identity.
- [Runbook](./Runbook.md) — how to consume, edit SOPS secrets, and protect the
  repo.
- [Troubleshooting](./Troubleshooting.md) — missing tool enablement, identity
  leakage, SOPS decrypt failures.
- [Reference](./Reference.md) — the `identities.*` option namespace and
  generated files.

## User-facing docs

The user guide lives in the repo [README](../README.md) (import, option shape,
generated files, secrets). It is the canonical source for consumers; this
`docs/` directory owns internal ops only and links out rather than duplicating
it.
