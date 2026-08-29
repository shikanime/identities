<!-- owner: shikanime | zone: internal | purpose: how to consume, edit secrets, and protect the repo without surprises -->

# Runbook

This repo is a module library, not a deployable service. "Operations" means
keeping identity fragments correct and the SOPS secrets rotatable.

## Consuming the modules

In a Home Manager config, import both `sops-nix.homeModules.default` and the
identities module, then enable the identities you want:

```nix
modules = [ sops-nix.homeModules.default identities.homeModules.default ];
identities.shikanime.enable = true;
identities.gouv.enable = true;     # scoped via git.condition
identities.automata.enable = true; # scoped via git.condition
```

The consumer must itself enable `programs.git` / `programs.jujutsu`; this repo
only emits fragments.

## Editing secrets

Secrets are encrypted with age key
`age1pwl9yz4k4255a4h8qz7lafce8wxhsul0cnqwmr8528fqgujlfshshv3z3g`. Edit one with:

```bash
sops secrets/<name>.enc.yaml
```

Decryption fails if the age key is absent from the local keychain — keep it on
any machine that builds the consumer config.

## Releasing

There is no tag or publish step — consumers pin `github:shikanime/identities`
(or `x-shikanime/identities`) by rev through their flake. A change is "released"
the moment it merges to `main`; downstream flake updates pull it in.

## Branch protection

`main` requires one approving review, linear history, signed commits, and
squash+rebase only. PRs are the merge path; direct pushes are rejected.

## CI

`.github/workflows/` runs the format/eval pass on every PR, plus Renovate for
flake input bumps. Land bumps on `main` via squash+rebase (see `AGENTS.md`).
